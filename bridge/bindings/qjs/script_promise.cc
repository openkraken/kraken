/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_promise.h"
#include "qjs_engine_patch.h"

namespace kraken {

ScriptPromise::ScriptPromise(JSContext* ctx, JSValue promise) : ctx_(ctx) {
  if (JS_IsUndefined(promise) || JS_IsNull(promise))
    return;

  if (!JS_IsPromise(promise)) {
    return;
  }

  promise_ = ScriptValue(ctx, promise);
}

JSValue ScriptPromise::ToQuickJS() {
  return JS_NULL;
}

void ScriptPromise::Trace(GCVisitor* visitor) {}

}  // namespace kraken
