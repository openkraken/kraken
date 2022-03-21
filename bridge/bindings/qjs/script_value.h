/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_SCRIPT_VALUE_H
#define KRAKENBRIDGE_SCRIPT_VALUE_H

#include <quickjs/quickjs.h>
#include <memory>

#include "exception_state.h"
#include "foundation/macros.h"
#include "foundation/native_string.h"

namespace kraken {

class ExecutingContext;
class WrapperTypeInfo;

// ScriptValue is a stack allocate only QuickJS JSValue wrapper ScriptValuewhich hold all information to hide out QuickJS running details.
class ScriptValue final {
  // ScriptValue should only allocate at stack.
  KRAKEN_DISALLOW_NEW();

 public:
  // Create an errorObject from string error message.
  static ScriptValue createErrorObject(JSContext* ctx, const char* errmsg);
  // Create an object from JSON string.
  static ScriptValue createJSONObject(JSContext* ctx, const char* jsonString, size_t length);
  // Create from NativeString
  static ScriptValue fromNativeString(JSContext* ctx, NativeString* nativeString);

  // Create an empty ScriptValue;
  static ScriptValue Empty(JSContext* ctx);
  // Wrap an Quickjs JSValue to ScriptValue.
  explicit ScriptValue(JSContext* ctx, JSValue value) : m_ctx(ctx), m_value(JS_DupValue(ctx, value)){};
  explicit ScriptValue(JSContext* ctx) : m_ctx(ctx){};
  ScriptValue() = default;

  ScriptValue& operator=(const ScriptValue& other) {
    if (&other != this) {
      m_value = JS_DupValue(m_ctx, other.m_value);
    }
    return *this;
  };
  ~ScriptValue() { JS_FreeValue(m_ctx, m_value); };

  JSValue ToQuickJS() const;
  // Create a new ScriptValue from call JSON.stringify to current value.
  ScriptValue ToJSONStringify(ExceptionState* exception);
  std::unique_ptr<NativeString> toNativeString();
  std::string toCString();

  bool IsException();
  bool IsEmpty();

 private:
  JSContext* m_ctx{nullptr};
  JSValue m_value{JS_NULL};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_SCRIPT_VALUE_H
