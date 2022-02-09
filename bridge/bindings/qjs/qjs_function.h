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
class QJSFunction : public GarbageCollected<QJSFunction> {
 public:
  static QJSFunction* create(JSContext* ctx, JSValue function) { return makeGarbageCollected<QJSFunction>(ctx, function); }
  explicit QJSFunction(JSContext* ctx, JSValue function) : m_function(JS_DupValue(ctx, function)), GarbageCollected<QJSFunction>(ctx){};

  bool isFunction(JSContext* ctx);

  // Performs "invoke".
  // https://webidl.spec.whatwg.org/#invoke-a-callback-function
  ScriptValue invoke(JSContext* ctx, int32_t argc, ScriptValue* arguments);

  const char* getHumanReadableName() const override;
  void trace(GCVisitor* visitor) const override;
  void dispose() const override;

 private:
  JSValue m_function{JS_NULL};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_QJS_FUNCTION_H
