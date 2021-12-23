/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "timer.h"
#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/qjs_patch.h"
#include "dart_methods.h"

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken::binding::qjs {

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

static JSValue setTimeout(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue callbackValue = argv[0];
  JSValue timeoutValue = argv[1];

  if (!JS_IsObject(callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': parameter 1 (callback) must be a function.");
  }

  if (!JS_IsFunction(ctx, callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': parameter 1 (callback) must be a function.");
  }

  int32_t timeout;

  if (argc < 2 || JS_IsUndefined(timeoutValue)) {
    timeout = 0;
  } else if (JS_IsNumber(timeoutValue)) {
    JS_ToInt32(ctx, &timeout, timeoutValue);
  } else {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': parameter 2 (timeout) only can be a number or undefined.");
  }

#if FLUTTER_BACKEND
  if (getDartMethod()->setTimeout == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': dart method (setTimeout) is not registered.");
  }
#endif

  // Create a timer object to keep track timer callback.
  auto* timer = makeGarbageCollected<DOMTimer>(JS_DupValue(ctx, callbackValue))->initialize(context->ctx(), &DOMTimer::classId);

  auto timerId = getDartMethod()->setTimeout(timer, context->getContextId(), handleTransientCallback, timeout);

  // Register timerId.
  timer->setTimerId(timerId);

  context->timers()->installNewTimer(context, timerId, timer);

  // `-1` represents ffi error occurred.
  if (timerId == -1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': dart method (setTimeout) execute failed");
  }

  return JS_NewUint32(ctx, timerId);
}

static JSValue setInterval(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue callbackValue = argv[0];
  JSValue timeoutValue = argv[1];

  if (!JS_IsObject(callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': parameter 1 (callback) must be a function.");
  }

  if (!JS_IsFunction(ctx, callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': parameter 1 (callback) must be a function.");
  }

  int32_t timeout;

  if (argc < 2 || JS_IsUndefined(timeoutValue)) {
    timeout = 0;
  } else if (JS_IsNumber(timeoutValue)) {
    JS_ToInt32(ctx, &timeout, timeoutValue);
  } else {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': parameter 2 (timeout) only can be a number or undefined.");
  }

  if (getDartMethod()->setInterval == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': dart method (setInterval) is not registered.");
  }

  // Create a timer object to keep track timer callback.
  auto* timer = makeGarbageCollected<DOMTimer>(JS_DupValue(ctx, callbackValue))->initialize(context->ctx(), &DOMTimer::classId);

  uint32_t timerId = getDartMethod()->setInterval(timer, context->getContextId(), handlePersistentCallback, timeout);

  // Register timerId.
  timer->setTimerId(timerId);
  context->timers()->installNewTimer(context, timerId, timer);

  if (timerId == -1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': dart method (setInterval) got unexpected error.");
  }

  return JS_NewUint32(ctx, timerId);
}

static JSValue clearTimeout(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc <= 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'clearTimeout': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));

  JSValue timeIdValue = argv[0];
  if (!JS_IsNumber(timeIdValue)) {
    return JS_NULL;
  }

  int32_t id;
  JS_ToInt32(ctx, &id, timeIdValue);

  if (getDartMethod()->clearTimeout == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'clearTimeout': dart method (clearTimeout) is not registered.");
  }

  getDartMethod()->clearTimeout(context->getContextId(), id);

  context->timers()->removeTimeoutById(id);
  return JS_NULL;
}

void bindTimer(std::unique_ptr<ExecutionContext>& context) {
  QJS_GLOBAL_BINDING_FUNCTION(context, setTimeout, "setTimeout", 2);
  QJS_GLOBAL_BINDING_FUNCTION(context, setInterval, "setInterval", 2);
  QJS_GLOBAL_BINDING_FUNCTION(context, clearTimeout, "clearTimeout", 1);
  QJS_GLOBAL_BINDING_FUNCTION(context, clearTimeout, "clearInterval", 1);
}
}  // namespace kraken::binding::qjs
