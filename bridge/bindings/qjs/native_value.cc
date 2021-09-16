/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "native_value.h"
#include "bindings/qjs/qjs_patch.h"
#include "kraken_bridge.h"
#include "dom/element.h"
#include "dom/elements/.gen/image_element.h"
#include "dom/elements/.gen/canvas_element.h"

namespace kraken::binding::qjs {

NativeValue Native_NewNull() {
  return (NativeValue){
    0,
    .u = {.int64 = 0},
    NativeTag::TAG_NULL
  };
}

NativeValue Native_NewString(NativeString *string) {
  return (NativeValue){
    0,
    .u = {.ptr = static_cast<void *>(string)},
    NativeTag::TAG_STRING,
  };
}

NativeValue Native_NewCString(std::string string) {
  NativeString *nativeString = stringToNativeString(string);
  return Native_NewString(nativeString);
}

NativeValue Native_NewFloat64(double value) {
  return (NativeValue){
    value,
    .u = {.ptr = nullptr},
    NativeTag::TAG_FLOAT64,
  };
}

NativeValue Native_NewPtr(JSPointerType pointerType, void *ptr) {
  return (NativeValue){
    static_cast<double>(pointerType),
    .u = {.ptr = ptr},
    NativeTag::TAG_POINTER
  };
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

NativeValue Native_NewJSON(JSContext *context, JSValue &value) {
  JSValue stringifiedValue = JS_JSONStringify(context->ctx(), value, JS_UNDEFINED, JS_UNDEFINED);
  NativeString *string = jsValueToNativeString(context->ctx(), stringifiedValue);
  return (NativeValue){
      0,
      .u = {.ptr = static_cast<void *>(string)},
      NativeTag::TAG_JSON,
  };
}

void call_native_function(NativeFunctionContext *functionContext, int32_t argc, NativeValue *argv, NativeValue *returnValue) {
  auto *context = functionContext->m_context;
  auto *arguments = new JSValue[argc];
  for (int i = 0; i < argc; i ++) {
    arguments[i] = nativeValueToJSValue(context, argv[i]);
  }
  JSValue result = JS_Call(context->ctx(), functionContext->m_callback, context->global(), argc, arguments);
  if (context->handleException(&result)) {
    *returnValue = jsValueToNativeValue(context->ctx(), result);
  }

  JS_FreeValue(context->ctx(), result);

  for (int i = 0; i < argc; i ++) {
    JS_FreeValue(context->ctx(), arguments[i]);
  }
  delete[] arguments;
  delete functionContext;
}

NativeValue jsValueToNativeValue(QjsContext *ctx, JSValue &value) {
  if (JS_IsNull(value) || JS_IsUndefined(value)) {
    return Native_NewNull();
  } else if (JS_IsBool(value)) {
    return Native_NewBool(JS_ToBool(ctx, value));
  } else if (JS_IsNumber(value)) {
    double v;
    JS_ToFloat64(ctx, &v, value);
    return Native_NewFloat64(v);
  } else if (JS_IsString(value)) {
    NativeString *string = jsValueToNativeString(ctx, value);
    return Native_NewString(string);
  } else if (JS_IsFunction(ctx, value)) {
    auto *context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
    auto *functionContext = new NativeFunctionContext{
      context,
      value
    };
    return Native_NewPtr(JSPointerType::NativeFunctionContext, functionContext);
  } else if (JS_IsObject(value)) {
    auto *context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
    if (JS_IsInstanceOf(ctx, value, ImageElement::instance(context)->classObject)) {
      auto *imageElementInstance = static_cast<ImageElementInstance *>(JS_GetOpaque(value, Element::classId()));
      return Native_NewPtr(JSPointerType::NativeEventTarget, imageElementInstance->nativeEventTarget);
    }

    JSValue stringifiedString = JS_JSONStringify(ctx, value, JS_UNDEFINED, JS_UNDEFINED);
    NativeString *string = jsValueToNativeString(ctx, stringifiedString);
    return Native_NewString(string);
  }

  return Native_NewNull();
}

NativeFunctionContext::NativeFunctionContext(JSContext *context, JSValue callback): m_context(context), m_ctx(context->ctx()), m_callback(callback), call(call_native_function) {
  JS_DupValue(context->ctx(), callback);
  list_add_tail(&link, &m_context->native_function_job_list);
};

NativeFunctionContext::~NativeFunctionContext() {
  list_del(&link);
  JS_FreeValue(m_ctx, m_callback);
}

static JSValue anonymousFunction(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv, int magic, JSValue *func_data) {
  auto id = magic;
  auto *eventTarget = static_cast<EventTargetInstance *>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));

  std::string call_params = "_anonymous_fn_" + std::to_string(id);

  auto *arguments = new NativeValue[argc];
  for (int i = 0; i < argc; i ++) {
    arguments[i] = jsValueToNativeValue(ctx, argv[i]);
  }

  JSValue returnValue = eventTarget->callNativeMethods(call_params.c_str(), argc, arguments);
  delete[] arguments;
  return returnValue;
}

JSValue nativeValueToJSValue(JSContext *context, NativeValue &value) {
  switch (value.tag) {
  case NativeTag::TAG_STRING: {
    auto *string = static_cast<NativeString *>(value.u.ptr);
    if (string == nullptr) return JS_NULL;
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
    auto *str = static_cast<const char *>(value.u.ptr);
    JSValue returnedValue = JS_ParseJSON(context->ctx(), str, strlen(str), "");
    delete str;
    return returnedValue;
  }
  case NativeTag::TAG_POINTER: {
    auto *ptr = value.u.ptr;
    int ptrType = (int)value.float64;
    if (ptrType == JSPointerType::NativeBoundingClientRect) {
      return (new BoundingClientRect(context, static_cast<NativeBoundingClientRect *>(ptr)))->jsObject;
    } else if (ptrType == JSPointerType::NativeCanvasRenderingContext2D) {
      return (new CanvasRenderingContext2D(context, static_cast<NativeCanvasRenderingContext2D *>(ptr)))->jsObject;
    } else if (ptrType == JSPointerType::NativeEventTarget) {
      auto *nativeEventTarget = static_cast<NativeEventTarget *>(ptr);
      return JS_DupValue(context->ctx(), nativeEventTarget->instance->instanceObject);
    }
  }
  case NativeTag::TAG_FUNCTION: {
    int64_t functionId = value.u.int64;
    return JS_NewCFunctionData(context->ctx(), anonymousFunction, 4, functionId, 0, nullptr);
  }
  }
  return JS_NULL;
}

} // namespace kraken::binding::qjs
