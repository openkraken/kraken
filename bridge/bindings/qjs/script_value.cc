/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_value.h"
#include "native_string_utils.h"
#include "qjs_engine_patch.h"

namespace kraken {

ScriptValue ScriptValue::createErrorObject(JSContext* ctx, const char* errmsg) {
  JS_ThrowInternalError(ctx, "%s", errmsg);
  JSValue errorObject = JS_GetException(ctx);
  ScriptValue result = ScriptValue(ctx, errorObject);
  JS_FreeValue(ctx, errorObject);
  return result;
}

ScriptValue ScriptValue::createJSONObject(JSContext* ctx, const char* jsonString, size_t length) {
  JSValue jsonValue = JS_ParseJSON(ctx, jsonString, length, "");
  ScriptValue result = ScriptValue(ctx, jsonValue);
  JS_FreeValue(ctx, jsonValue);
  return result;
}

ScriptValue ScriptValue::fromNativeString(JSContext* ctx, NativeString* nativeString) {
  JSValue result = JS_NewUnicodeString(JS_GetRuntime(ctx), ctx, nativeString->string, nativeString->length);
  return ScriptValue(ctx, result);
}

ScriptValue ScriptValue::Empty(JSContext* ctx) {
  return ScriptValue(ctx);
}

bool ScriptValue::isEmpty() {
  return JS_IsNull(m_value);
}

bool ScriptValue::isString() {
  return JS_IsString(m_value);
}

JSValue ScriptValue::toQuickJS() {
  return m_value;
}

ScriptValue ScriptValue::toJSONStringify(ExceptionState* exception) {
  JSValue stringifyedValue = JS_JSONStringify(m_ctx, m_value, JS_NULL, JS_NULL);
  ScriptValue result = ScriptValue(m_ctx);
  // JS_JSONStringify may return JS_EXCEPTION if object is not valid. Return JS_EXCEPTION and let quickjs to handle it.
  if (JS_IsException(stringifyedValue)) {
    exception->throwException(m_ctx, stringifyedValue);
    result = ScriptValue(m_ctx, stringifyedValue);
  } else {
    result = ScriptValue(m_ctx, stringifyedValue);
  }

  return result;
}

std::unique_ptr<NativeString> ScriptValue::toNativeString() {
  return jsValueToNativeString(m_ctx, m_value);
}

std::string ScriptValue::toCString() {
  return jsValueToStdString(m_ctx, m_value);
}

bool ScriptValue::isException() {
  return JS_IsException(m_value);
}

}  // namespace kraken
