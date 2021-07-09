/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "native_value.h"
#include "bindings/qjs/qjs_patch.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

NativeValue Native_NewString(NativeString *string) {
  return (NativeValue){
    0,
    .u = {.ptr = static_cast<void *>(string)},
    NativeTag::TAG_STRING,
  };
}

NativeValue Native_NewFloat64(double value) {
  return (NativeValue){
    value,
    .u = {.ptr = nullptr},
    NativeTag::TAG_FLOAT64,
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
  }
  return JS_NULL;
}

} // namespace kraken::binding::qjs
