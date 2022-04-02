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
#include "gc_visitor.h"

namespace kraken {

class ExecutingContext;
class WrapperTypeInfo;

// ScriptValue is a stack allocate only QuickJS JSValue wrapper ScriptValuewhich hold all information to hide out
// QuickJS running details.
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
  explicit ScriptValue(JSContext* ctx, JSValue value) : ctx_(ctx), value_(JS_DupValue(ctx, value)){};
  explicit ScriptValue(JSContext* ctx) : ctx_(ctx){};
  ScriptValue() = default;

  // Copy and assignment
  ScriptValue(ScriptValue const& value) {
    if (&value != this) {
      value_ = JS_DupValue(ctx_, value.value_);
    }
    ctx_ = value.ctx_;
  };
  ScriptValue& operator=(const ScriptValue& value) {
    if (&value != this) {
      value_ = JS_DupValue(ctx_, value.value_);
    }
    ctx_ = value.ctx_;
    return *this;
  }

  // Move operations
  ScriptValue(ScriptValue&& value) noexcept {
    if (&value != this) {
      value_ = JS_DupValue(ctx_, value.value_);
    }
    ctx_ = value.ctx_;
  };
  ScriptValue& operator=(ScriptValue&& value) noexcept {
    if (&value != this) {
      value_ = JS_DupValue(ctx_, value.value_);
    }
    ctx_ = value.ctx_;
    return *this;
  }

  ~ScriptValue() { JS_FreeValue(ctx_, value_); };

  JSValue ToQuickJS() const;
  // Create a new ScriptValue from call JSON.stringify to current value.
  ScriptValue ToJSONStringify(ExceptionState* exception);
  std::unique_ptr<NativeString> toNativeString();
  std::string toCString();

  bool IsException();
  bool IsEmpty();

  void Trace(GCVisitor* visitor);

 private:
  JSContext* ctx_{nullptr};
  JSValue value_{JS_NULL};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_SCRIPT_VALUE_H
