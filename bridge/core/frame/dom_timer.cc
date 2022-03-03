/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dom_timer.h"
#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/qjs_engine_patch.h"
#include "core/executing_context.h"

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken {

DOMTimer::DOMTimer(JSContext* ctx, QJSFunction* callback) : callback_(callback), ScriptWrappable(ctx) {}

void DOMTimer::fire() {
  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx()));
  if (!callback_->IsFunction(ctx()))
    return;

  ScriptValue returnValue = callback_->Invoke(ctx(), 0, nullptr);

  if (returnValue.isException()) {
    context->handleException(&returnValue);
  }
}

void DOMTimer::Trace(GCVisitor* visitor) const {
  callback_->Trace(visitor);
}

void DOMTimer::Dispose() const {
  callback_->Dispose();
}

int32_t DOMTimer::timerId() {
  return timerId_;
}

void DOMTimer::setTimerId(int32_t timerId) {
  timerId_ = timerId;
}

}  // namespace kraken
