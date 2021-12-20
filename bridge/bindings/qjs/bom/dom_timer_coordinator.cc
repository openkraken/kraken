/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dom_timer_coordinator.h"
#include "dart_methods.h"
#include "timer.h"

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken::binding::qjs {

static void handleTimerCallback(DOMTimer* timer, const char* errmsg) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(timer->ctx()));

  if (errmsg != nullptr) {
    JSValue exception = JS_ThrowTypeError(timer->ctx(), "%s", errmsg);
    context->handleException(&exception);
    return;
  }

  // Trigger timer callbacks.
  timer->fire();

  // Executing pending async jobs.
  context->drainPendingPromiseJobs();
}

static void handleTransientCallback(void* ptr, int32_t contextId, const char* errmsg) {
  auto* timer = static_cast<DOMTimer*>(ptr);
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(timer->ctx()));

  if (!checkPage(contextId, context))
    return;
  if (!context->isValid())
    return;

  handleTimerCallback(timer, errmsg);

  context->timers()->removeTimeoutById(timer->timerId());
}

void DOMTimerCoordinator::installNewTimer(ExecutionContext* context, int32_t timerId, DOMTimer* timer) {
  m_activeTimers[timerId] = timer;
}

void* DOMTimerCoordinator::removeTimeoutById(int32_t timerId) {
  if (m_activeTimers.count(timerId) == 0)
    return nullptr;
  DOMTimer* timer = m_activeTimers[timerId];

  // Push this timer to abandoned list to mark this timer is deprecated.
  m_abandonedTimers.emplace_back(timer);

  m_activeTimers.erase(timerId);
  return nullptr;
}

DOMTimer* DOMTimerCoordinator::getTimerById(int32_t timerId) {
  if (m_activeTimers.count(timerId) == 0)
    return nullptr;
  return m_activeTimers[timerId];
}

void DOMTimerCoordinator::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  for (auto& timer : m_activeTimers) {
    JS_MarkValue(rt, timer.second->toQuickJS(), mark_func);
  }

  // Recycle all abandoned timers.
  if (!m_abandonedTimers.empty()) {
    for (auto& timer : m_abandonedTimers) {
      JS_MarkValue(rt, timer->toQuickJS(), mark_func);
    }
    // All abandoned timers should be freed at the sweep stage.
    m_abandonedTimers.clear();
  }
}

}  // namespace kraken::binding::qjs
