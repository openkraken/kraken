/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "native_value.h"
#include "bindings/qjs/qjs_engine_patch.h"
#include "bindings/qjs/script_value.h"
#include "core/executing_context.h"

namespace kraken {

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

NativeValue Native_NewInt64(int64_t value) {
  return (NativeValue){
      0,
      .u = {.int64 = value},
      NativeTag::TAG_INT,
  };
}

NativeValue Native_NewJSON(const ScriptValue& value) {
  ExceptionState exception_state;
  ScriptValue json = value.ToJSONStringify(&exception_state);
  if (exception_state.HasException()) {
    return Native_NewNull();
  }

  AtomicString str = json.ToString();
  auto native_string = str.ToNativeString();
  NativeValue result = (NativeValue){
      0,
      .u = {.ptr = static_cast<void*>(native_string.release())},
      NativeTag::TAG_JSON,
  };
  return result;
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
      return Native_NewInt64(v);
    }
  } else if (JS_IsString(value)) {
    // NativeString owned by NativeValue will be freed by users.
    NativeString* string = jsValueToNativeString(ctx, value).release();
    return Native_NewString(string);
  } else if (JS_IsFunction(ctx, value)) {
    auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
    auto* functionContext = new NativeFunctionContext{context, value};
    return Native_NewPtr(JSPointerType::NativeFunctionContext, functionContext);
  } else if (JS_IsObject(value)) {
    //    auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
    //    if (JS_IsInstanceOf(ctx, value, ImageElement::instance(context)->jsObject)) {
    //      auto* imageElementInstance = static_cast<ImageElementInstance*>(JS_GetOpaque(value, Element::classId()));
    //      return Native_NewPtr(JSPointerType::NativeEventTarget, imageElementInstance->nativeEventTarget);
    //    }
    //    return Native_NewJSON(context, value);
  }

  return Native_NewNull();
}

NativeFunctionContext::NativeFunctionContext(ExecutingContext* context, JSValue callback)
    : m_context(context), m_ctx(context->ctx()), m_callback(callback), call(call_native_function) {
  JS_DupValue(context->ctx(), callback);
  list_add_tail(&link, &m_context->native_function_job_list);
};

NativeFunctionContext::~NativeFunctionContext() {
  list_del(&link);
  JS_FreeValue(m_ctx, m_callback);
}

JSValue nativeValueToJSValue(ExecutingContext* context, NativeValue& value) {
  switch (value.tag) {
    case NativeTag::TAG_STRING: {
      //      auto* string = static_cast<NativeString*>(value.u.ptr);
      //      if (string == nullptr)
      //        return JS_NULL;
      //      JSValue returnedValue = JS_NewUnicodeString(context->runtime(), context->ctx(), string->string,
      //      string->length); string->free(); return returnedValue;
    }
    case NativeTag::TAG_INT: {
      return JS_NewUint32(context->ctx(), value.u.int64);
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
      //      if (ptrType == static_cast<int64_t>(JSPointerType::NativeBoundingClientRect)) {
      //        return (new BoundingClientRect(context, static_cast<NativeBoundingClientRect*>(ptr)))->jsObject;
      //      } else if (ptrType == static_cast<int64_t>(JSPointerType::NativeCanvasRenderingContext2D)) {
      //        return (new CanvasRenderingContext2D(context,
      //        static_cast<NativeCanvasRenderingContext2D*>(ptr)))->jsObject;
      //      } else if (ptrType == static_cast<int64_t>(JSPointerType::NativeEventTarget)) {
      //        auto* nativeEventTarget = static_cast<NativeEventTarget*>(ptr);
      //        return JS_DupValue(context->ctx(), nativeEventTarget->instance->jsObject);
      //      }
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

std::string nativeStringToStdString(NativeString* nativeString) {
  std::u16string u16EventType =
      std::u16string(reinterpret_cast<const char16_t*>(nativeString->string()), nativeString->length());
  return toUTF8(u16EventType);
}

}  // namespace kraken
