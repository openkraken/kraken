/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_QJS_FUNCTION_H
#define KRAKENBRIDGE_QJS_FUNCTION_H

#include "garbage_collected.h"
#include "script_value.h"

namespace kraken {

// https://webidl.spec.whatwg.org/#dfn-callback-interface
class QJSFunction {
 public:
  static std::shared_ptr<QJSFunction> Create(JSContext* ctx, JSValue function) { return std::make_shared<QJSFunction>(ctx, function); }
  explicit QJSFunction(JSContext* ctx, JSValue function) : function_(JS_DupValue(ctx, function)) {};

  bool IsFunction(JSContext* ctx);

  // Performs "invoke".
  // https://webidl.spec.whatwg.org/#invoke-a-callback-function
  ScriptValue Invoke(JSContext* ctx, int32_t argc, ScriptValue* arguments);

  void Trace(GCVisitor* visitor) const;
  void Dispose() const;

 private:
  JSContext* ctx_{nullptr};
  JSValue function_{JS_NULL};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_QJS_FUNCTION_H
