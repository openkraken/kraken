/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_promise.h"

namespace kraken {

ScriptPromise::ScriptPromise(ExecutingContext* context, JSValue promise): context_(context) {
  if (JS_IsUndefined(promise) || JS_IsNull(promise)) return;

  if (!JS_IsPromise(promise)) {
    return;
  }

  promise_ = ScriptValue(context->ctx(), promise);
}

JSValue ScriptPromise::ToQuickJS() {
  return JS_NULL;
}

}
