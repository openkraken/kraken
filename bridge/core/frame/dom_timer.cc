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

DOMTimer::DOMTimer(QJSFunction* callback) : m_callback(callback) {}

JSClassID DOMTimer::classId{0};

void DOMTimer::fire() {
  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(m_ctx));
  if (!m_callback->isFunction(m_ctx))
    return;

  ScriptValue returnValue = m_callback->invoke(m_ctx, 0, nullptr);

  if (returnValue.isException()) {
    context->handleException(&returnValue);
  }
}

void DOMTimer::trace(GCVisitor* visitor) const {
  m_callback->trace(visitor);
}

void DOMTimer::dispose() const {
  m_callback->dispose();
}

int32_t DOMTimer::timerId() {
  return m_timerId;
}

void DOMTimer::setTimerId(int32_t timerId) {
  m_timerId = timerId;
}

}  // namespace kraken
