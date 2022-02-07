/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dom_timer.h"
#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/qjs_patch.h"
#include "core/dart_methods.h"

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken {

DOMTimer::DOMTimer(JSValue callback) : m_callback(callback) {}

JSClassID DOMTimer::classId{0};

void DOMTimer::fire() {
  // 'callback' might be destroyed when calling itself (if it frees the handler), so must take extra care.
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(m_ctx));
  if (!JS_IsFunction(m_ctx, m_callback))
    return;

  JS_DupValue(m_ctx, m_callback);
  JSValue returnValue = JS_Call(m_ctx, m_callback, JS_UNDEFINED, 0, nullptr);
  JS_FreeValue(m_ctx, m_callback);

  if (JS_IsException(returnValue)) {
    context->handleException(&returnValue);
  }

  JS_FreeValue(m_ctx, returnValue);
}

void DOMTimer::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  JS_MarkValue(rt, m_callback, mark_func);
}

void DOMTimer::dispose() const {
  JS_FreeValueRT(m_runtime, m_callback);
}

int32_t DOMTimer::timerId() {
  return m_timerId;
}

void DOMTimer::setTimerId(int32_t timerId) {
  m_timerId = timerId;
}

static void handleTimerCallback(DOMTimer* timer, const char* errmsg) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(timer->ctx()));

  if (errmsg != nullptr) {
    JSValue exception = JS_ThrowTypeError(timer->ctx(), "%s", errmsg);
    context->handleException(&exception);
    return;
  }

  if (context->timers()->getTimerById(timer->timerId()) == nullptr)
    return;

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

static void handlePersistentCallback(void* ptr, int32_t contextId, const char* errmsg) {
  auto* timer = static_cast<DOMTimer*>(ptr);
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(timer->ctx()));

  if (!checkPage(contextId, context))
    return;
  if (!context->isValid())
    return;

  handleTimerCallback(timer, errmsg);
}
}  // namespace kraken
