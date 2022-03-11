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

DOMTimer::DOMTimer(ExecutingContext* context, QJSFunction* callback) : context_(context), callback_(callback) {}

void DOMTimer::Fire() {
  if (!callback_->IsFunction(context_->ctx()))
    return;

  ScriptValue returnValue = callback_->Invoke(context_->ctx(), 0, nullptr);

  if (returnValue.isException()) {
    context_->HandleException(&returnValue);
  }
}

void DOMTimer::Trace(GCVisitor* visitor) const {
  callback_->Trace(visitor);
}

void DOMTimer::Dispose() const {
  callback_->Dispose();
}

void DOMTimer::setTimerId(int32_t timerId) {
  timerId_ = timerId;
}

}  // namespace kraken
