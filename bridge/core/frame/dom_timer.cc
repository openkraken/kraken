/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dom_timer.h"

#include <utility>
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/qjs_engine_patch.h"
#include "core/executing_context.h"

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken {

std::shared_ptr<DOMTimer> DOMTimer::create(ExecutingContext* context, const std::shared_ptr<QJSFunction>& callback) {
  return std::make_shared<DOMTimer>(context, callback);
}

DOMTimer::DOMTimer(ExecutingContext* context, std::shared_ptr<QJSFunction> callback)
    : context_(context), callback_(std::move(callback)), status_(TimerStatus::kPending) {}

void DOMTimer::Fire() {
  if (!callback_->IsFunction(context_->ctx()))
    return;

  ScriptValue returnValue = callback_->Invoke(context_->ctx(), ScriptValue::Empty(context_->ctx()), 0, nullptr);

  if (returnValue.IsException()) {
    context_->HandleException(&returnValue);
  }
}

void DOMTimer::setTimerId(int32_t timerId) {
  timerId_ = timerId;
}

}  // namespace kraken
