/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_QJS_FUNCTION_H
#define KRAKENBRIDGE_QJS_FUNCTION_H

#include "garbage_collected.h"

namespace kraken {

// https://webidl.spec.whatwg.org/#dfn-callback-interface
class QJSFunction : public GarbageCollected<QJSFunction> {
 public:
  static QJSFunction* create(JSContext* ctx, JSValue function) { return makeGarbageCollected<QJSFunction>(ctx, function); }

  explicit QJSFunction(JSContext* ctx, JSValue function) : m_function(JS_DupValue(ctx, function)){};

  const char* getHumanReadableName() const override;

  [[nodiscard]]

  void
  trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;

 private:
  JSValue m_function{JS_NULL};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_QJS_FUNCTION_H
