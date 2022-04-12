/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_TO_QUICKJS_H_
#define KRAKENBRIDGE_BINDINGS_QJS_TO_QUICKJS_H_

#include <quickjs/quickjs.h>
#include <string>
#include "core/fileapi/array_buffer_data.h"
#include "native_string_utils.h"
#include "qjs_engine_patch.h"
#include "script_wrappable.h"

namespace kraken {

// Arithmetic values
inline JSValue toQuickJS(JSContext* ctx, double v) {
  return JS_NewFloat64(ctx, v);
}
inline JSValue toQuickJS(JSContext* ctx, int32_t v) {
  return JS_NewInt32(ctx, v);
}
inline JSValue toQuickJS(JSContext* ctx, uint32_t v) {
  return JS_NewUint32(ctx, v);
}
inline JSValue toQuickJS(JSContext* ctx, ExceptionState& exception_state) {
  return exception_state.ToQuickJS();
};

// String
inline JSValue toQuickJS(JSContext* ctx, const std::string& str) {
  return JS_NewString(ctx, str.c_str());
}
inline JSValue toQuickJS(JSContext* ctx, const char* str) {
  return JS_NewString(ctx, str);
}
inline JSValue toQuickJS(JSContext* ctx, std::unique_ptr<NativeString>& str) {
  return JS_NewUnicodeString(ctx, str->string(), str->length());
}
inline JSValue toQuickJS(JSContext* ctx, NativeString* str) {
  return JS_NewUnicodeString(ctx, str->string(), str->length());
}

// ScriptWrapper
inline JSValue toQuickJS(JSContext* ctx, ScriptWrappable* wrapper) {
  return wrapper->ToQuickJS();
}
inline JSValue toQuickJS(JSContext* ctx, ArrayBufferData data) {
  return JS_NewArrayBufferCopy(ctx, data.buffer, data.length);
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_TO_QUICKJS_H_
