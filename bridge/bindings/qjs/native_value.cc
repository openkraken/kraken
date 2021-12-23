/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "native_value.h"
#include "bindings/qjs/dom/elements/image_element.h"
#include "bindings/qjs/qjs_patch.h"
#include "dom/element.h"
#include "dom/elements/.gen/canvas_element.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

#define AnonymousFunctionCallPreFix "_anonymous_fn_"
#define AsyncAnonymousFunctionCallPreFix "_anonymous_async_fn_"

NativeValue Native_NewNull() {
  return (NativeValue){0, .u = {.int64 = 0}, NativeTag::TAG_NULL};
}

NativeValue Native_NewString(NativeString* string) {
  return (NativeValue){
      0,
      .u = {.ptr = static_cast<void*>(string)},
      NativeTag::TAG_STRING,
  };
}

NativeValue Native_NewCString(std::string string) {
  std::unique_ptr<NativeString> nativeString = stringToNativeString(string);
  // NativeString owned by NativeValue will be freed by users.
  return Native_NewString(nativeString.release());
}

NativeValue Native_NewFloat64(double value) {
  return (NativeValue){
      value,
      .u = {.ptr = nullptr},
      NativeTag::TAG_FLOAT64,
  };
}

NativeValue Native_NewPtr(JSPointerType pointerType, void* ptr) {
  return (NativeValue){static_cast<double>(pointerType), .u = {.ptr = ptr}, NativeTag::TAG_POINTER};
}

NativeValue Native_NewBool(bool value) {
  return (NativeValue){
      0,
      .u = {.int64 = value ? 1 : 0},
      NativeTag::TAG_BOOL,
  };
}

NativeValue Native_NewInt32(int32_t value) {
  return (NativeValue){
      0,
      .u = {.int64 = value},
      NativeTag::TAG_INT,
  };
}

NativeValue Native_NewJSON(ExecutionContext* context, JSValue& value) {
  JSValue stringifiedValue = JS_JSONStringify(context->ctx(), value, JS_UNDEFINED, JS_UNDEFINED);
  if (JS_IsException(stringifiedValue))
    return Native_NewNull();

  // NativeString owned by NativeValue will be freed by users.
  NativeString* string = jsValueToNativeString(context->ctx(), stringifiedValue).release();
  NativeValue result = (NativeValue){
      0,
      .u = {.ptr = static_cast<void*>(string)},
      NativeTag::TAG_JSON,
  };
  JS_FreeValue(context->ctx(), stringifiedValue);
  return result;
}

void call_native_function(NativeFunctionContext* functionContext, int32_t argc, NativeValue* argv, NativeValue* returnValue) {
  auto* context = functionContext->m_context;
  auto* arguments = new JSValue[argc];
  for (int i = 0; i < argc; i++) {
    arguments[i] = nativeValueToJSValue(context, argv[i]);
  }
  JSValue result = JS_Call(context->ctx(), functionContext->m_callback, context->global(), argc, arguments);
  context->drainPendingPromiseJobs();
  if (context->handleException(&result)) {
    *returnValue = jsValueToNativeValue(context->ctx(), result);
  }

  JS_FreeValue(context->ctx(), result);

  for (int i = 0; i < argc; i++) {
    JS_FreeValue(context->ctx(), arguments[i]);
  }
  delete[] arguments;
  delete functionContext;
}

NativeValue jsValueToNativeValue(JSContext* ctx, JSValue& value) {
  if (JS_IsNull(value) || JS_IsUndefined(value)) {
    return Native_NewNull();
  } else if (JS_IsBool(value)) {
    return Native_NewBool(JS_ToBool(ctx, value));
  } else if (JS_IsNumber(value)) {
    uint32_t tag = JS_VALUE_GET_TAG(value);
    if (JS_TAG_IS_FLOAT64(tag)) {
      double v;
      JS_ToFloat64(ctx, &v, value);
      return Native_NewFloat64(v);
    } else {
      int32_t v;
      JS_ToInt32(ctx, &v, value);
      return Native_NewInt32(v);
    }
  } else if (JS_IsString(value)) {
    // NativeString owned by NativeValue will be freed by users.
    NativeString* string = jsValueToNativeString(ctx, value).release();
    return Native_NewString(string);
  } else if (JS_IsFunction(ctx, value)) {
    auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
    auto* functionContext = new NativeFunctionContext{context, value};
    return Native_NewPtr(JSPointerType::NativeFunctionContext, functionContext);
  } else if (JS_IsObject(value)) {
    auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
    if (JS_IsInstanceOf(ctx, value, ImageElement::instance(context)->jsObject)) {
      auto* imageElementInstance = static_cast<ImageElementInstance*>(JS_GetOpaque(value, Element::classId()));
      return Native_NewPtr(JSPointerType::NativeEventTarget, imageElementInstance->nativeEventTarget);
    }

    return Native_NewJSON(context, value);
  }

  return Native_NewNull();
}

NativeFunctionContext::NativeFunctionContext(ExecutionContext* context, JSValue callback) : m_context(context), m_ctx(context->ctx()), m_callback(callback), call(call_native_function) {
  JS_DupValue(context->ctx(), callback);
  list_add_tail(&link, &m_context->native_function_job_list);
};

NativeFunctionContext::~NativeFunctionContext() {
  list_del(&link);
  JS_FreeValue(m_ctx, m_callback);
}

static JSValue anonymousFunction(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
  auto id = magic;
  auto* eventTarget = static_cast<EventTargetInstance*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));

  std::string call_params = AnonymousFunctionCallPreFix + std::to_string(id);

  auto* arguments = new NativeValue[argc];
  for (int i = 0; i < argc; i++) {
    arguments[i] = jsValueToNativeValue(ctx, argv[i]);
  }

  JSValue returnValue = eventTarget->callNativeMethods(call_params.c_str(), argc, arguments);
  delete[] arguments;
  return returnValue;
}

void anonymousAsyncCallback(void* callbackContext, NativeValue* nativeValue, int32_t contextId, const char* errmsg) {
  auto* promiseContext = static_cast<PromiseContext*>(callbackContext);
  if (!promiseContext->context->isValid())
    return;
  if (promiseContext->context->getContextId() != contextId)
    return;

  auto* context = promiseContext->context;

  if (nativeValue != nullptr) {
    JSValue value = nativeValueToJSValue(promiseContext->context, *nativeValue);
    JSValue returnValue = JS_Call(context->ctx(), promiseContext->resolveFunc, context->global(), 1, &value);
    context->drainPendingPromiseJobs();
    JS_FreeValue(context->ctx(), value);
    JS_FreeValue(context->ctx(), returnValue);
  } else if (errmsg != nullptr) {
    JSValue error = JS_NewError(context->ctx());
    JS_DefinePropertyValueStr(context->ctx(), error, "message", JS_NewString(context->ctx(), errmsg), JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
    JSValue returnValue = JS_Call(context->ctx(), promiseContext->rejectFunc, context->global(), 1, &error);
    context->drainPendingPromiseJobs();
    JS_FreeValue(context->ctx(), error);
    JS_FreeValue(context->ctx(), returnValue);
  }

  JS_FreeValue(context->ctx(), promiseContext->resolveFunc);
  JS_FreeValue(context->ctx(), promiseContext->rejectFunc);
  list_del(&promiseContext->link);
}

static JSValue anonymousAsyncFunction(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data) {
  JSValue resolving_funcs[2];
  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);

  auto id = magic;
  auto* eventTarget = static_cast<EventTargetInstance*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  auto* context = eventTarget->context();

  auto* promiseContext = new PromiseContext{eventTarget, context, resolving_funcs[0], resolving_funcs[1], promise};
  list_add_tail(&promiseContext->link, &context->promise_job_list);

  std::string call_params = AsyncAnonymousFunctionCallPreFix + std::to_string(id);

  auto* arguments = new NativeValue[argc + 3];

  arguments[0] = Native_NewInt32(context->getContextId());
  arguments[1] = Native_NewPtr(JSPointerType::AsyncContextContext, promiseContext);
  arguments[2] = Native_NewPtr(JSPointerType::AsyncContextContext, reinterpret_cast<void*>(anonymousAsyncCallback));
  for (int i = 0; i < argc; i++) {
    arguments[i + 3] = jsValueToNativeValue(ctx, argv[i]);
  }

  eventTarget->callNativeMethods(call_params.c_str(), argc + 3, arguments);
  delete[] arguments;

  return promise;
}

JSValue nativeValueToJSValue(ExecutionContext* context, NativeValue& value) {
  switch (value.tag) {
    case NativeTag::TAG_STRING: {
      auto* string = static_cast<NativeString*>(value.u.ptr);
      if (string == nullptr)
        return JS_NULL;
      JSValue returnedValue = JS_NewUnicodeString(context->runtime(), context->ctx(), string->string, string->length);
      string->free();
      return returnedValue;
    }
    case NativeTag::TAG_INT: {
      return JS_NewUint32(context->ctx(), value.u.int64);
    }
    case NativeTag::TAG_BOOL: {
      return JS_NewBool(context->ctx(), value.u.int64 == 1);
    }
    case NativeTag::TAG_FLOAT64: {
      return JS_NewFloat64(context->ctx(), value.float64);
    }
    case NativeTag::TAG_NULL: {
      return JS_NULL;
    }
    case NativeTag::TAG_JSON: {
      auto* str = static_cast<const char*>(value.u.ptr);
      JSValue returnedValue = JS_ParseJSON(context->ctx(), str, strlen(str), "");
      delete str;
      return returnedValue;
    }
    case NativeTag::TAG_POINTER: {
      auto* ptr = value.u.ptr;
      int ptrType = (int)value.float64;
      if (ptrType == static_cast<int64_t>(JSPointerType::NativeBoundingClientRect)) {
        return (new BoundingClientRect(context, static_cast<NativeBoundingClientRect*>(ptr)))->jsObject;
      } else if (ptrType == static_cast<int64_t>(JSPointerType::NativeCanvasRenderingContext2D)) {
        return (new CanvasRenderingContext2D(context, static_cast<NativeCanvasRenderingContext2D*>(ptr)))->jsObject;
      } else if (ptrType == static_cast<int64_t>(JSPointerType::NativeEventTarget)) {
        auto* nativeEventTarget = static_cast<NativeEventTarget*>(ptr);
        return JS_DupValue(context->ctx(), nativeEventTarget->instance->jsObject);
      }
    }
    case NativeTag::TAG_FUNCTION: {
      int64_t functionId = value.u.int64;
      return JS_NewCFunctionData(context->ctx(), anonymousFunction, 4, functionId, 0, nullptr);
    }
    case NativeTag::TAG_ASYNC_FUNCTION: {
      int64_t functionId = value.u.int64;
      return JS_NewCFunctionData(context->ctx(), anonymousAsyncFunction, 4, functionId, 0, nullptr);
    }
  }
  return JS_NULL;
}

}  // namespace kraken::binding::qjs
