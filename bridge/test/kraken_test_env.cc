/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_test_env.h"
#include <sys/time.h>
#include <vector>
#include "bindings/qjs/dom/event_target.h"
#include "kraken_bridge_test.h"

#if defined(__linux__) || defined(__APPLE__)
static int64_t get_time_ms(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (uint64_t)ts.tv_sec * 1000 + (ts.tv_nsec / 1000000);
}
#else
/* more portable, but does not work if the date is updated */
static int64_t get_time_ms(void) {
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return (int64_t)tv.tv_sec * 1000 + (tv.tv_usec / 1000);
}
#endif

typedef struct {
  struct list_head link;
  int64_t timeout;
  DOMTimer* timer;
  int32_t contextId;
  bool isInterval;
  AsyncCallback func;
} JSOSTimer;

typedef struct {
  struct list_head link;
  FrameCallback* callback;
  int32_t contextId;
  AsyncRAFCallback handler;
  int32_t callbackId;
} JSFrameCallback;

typedef struct JSThreadState {
  std::unordered_map<int32_t, JSOSTimer*> os_timers; /* list of timer.link */
  std::unordered_map<int32_t, JSFrameCallback*> os_frameCallbacks;
} JSThreadState;

static void unlink_timer(JSThreadState* ts, JSOSTimer* th) {
  ts->os_timers.erase(th->timer->timerId());
}

static void unlink_callback(JSThreadState* ts, JSFrameCallback* th) {
  ts->os_frameCallbacks.erase(th->callbackId);
}

void TEST_init(ExecutionContext* context) {
  JSThreadState* th = new JSThreadState();
  JS_SetRuntimeOpaque(context->runtime(), th);
}

int32_t timerId = 0;

int32_t TEST_setTimeout(DOMTimer* timer, int32_t contextId, AsyncCallback callback, int32_t timeout) {
  JSRuntime* rt = JS_GetRuntime(timer->ctx());
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(timer->ctx()));
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  JSOSTimer* th = static_cast<JSOSTimer*>(js_mallocz(context->ctx(), sizeof(*th)));
  th->timeout = get_time_ms() + timeout;
  th->func = callback;
  th->timer = timer;
  th->contextId = contextId;
  th->isInterval = false;
  int32_t id = timerId++;

  ts->os_timers[id] = th;

  return id;
}

int32_t TEST_setInterval(DOMTimer* timer, int32_t contextId, AsyncCallback callback, int32_t timeout) {
  JSRuntime* rt = JS_GetRuntime(timer->ctx());
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(timer->ctx()));
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  JSOSTimer* th = static_cast<JSOSTimer*>(js_mallocz(context->ctx(), sizeof(*th)));
  th->timeout = get_time_ms() + timeout;
  th->func = callback;
  th->timer = timer;
  th->contextId = contextId;
  th->isInterval = true;
  int32_t id = timerId++;

  ts->os_timers[id] = th;

  return id;
}


int32_t callbackId = 0;

uint32_t TEST_requestAnimationFrame(FrameCallback* frameCallback, AsyncRAFCallback handler) {
  JSRuntime* rt = JS_GetRuntime(frameCallback->ctx());
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(frameCallback->ctx()));
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  JSFrameCallback* th = static_cast<JSFrameCallback*>(js_mallocz(context->ctx(), sizeof(*th)));
  th->handler = handler;
  th->callback = frameCallback;
  th->contextId = context->getContextId();
  int32_t id = callbackId++;

  th->callbackId = id;

  ts->os_frameCallbacks[id] = th;

  return id;
}

void TEST_cancelAnimationFrame(JSContext* ctx, uint32_t callbackId) {
  JSRuntime* rt = JS_GetRuntime(ctx);
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  ts->os_frameCallbacks.erase(callbackId);
}

void TEST_clearTimeout(DOMTimer* timer) {
  JSRuntime* rt = JS_GetRuntime(timer->ctx());
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(timer->ctx()));
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  ts->os_timers.erase(timer->timerId());
}

static bool jsPool(ExecutionContext* context) {
  JSRuntime* rt = context->runtime();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  int64_t cur_time, delay;
  struct list_head* el;

  if (ts->os_timers.empty() && ts->os_frameCallbacks.empty())
    return true; /* no more events */

  if (!ts->os_timers.empty()) {
    cur_time = get_time_ms();
    for (auto& entry : ts->os_timers) {
      JSOSTimer* th = entry.second;
      delay = th->timeout - cur_time;
      if (delay <= 0) {
        AsyncCallback func;
        /* the timer expired */
        func = th->func;

        if (th->isInterval) {
          func(th->timer, th->contextId, nullptr);
        } else {
          th->func = nullptr;
          func(th->timer, th->contextId, nullptr);
          unlink_timer(ts, th);
        }

        return false;
      }
    }
  }

  if (!ts->os_frameCallbacks.empty()) {
    for (auto& entry : ts->os_frameCallbacks) {
      JSFrameCallback* th = entry.second;
      AsyncRAFCallback handler = th->handler;
      th->handler = nullptr;
      handler(th->callback, th->contextId, 0, nullptr);
      unlink_callback(ts, th);
      return false;
    }
  }

  return false;
}

void TEST_runLoop(ExecutionContext* context) {
  for (;;) {
    context->drainPendingPromiseJobs();
    if (jsPool(context))
      break;
  }
}

void TEST_dispatchEvent(EventTargetInstance* eventTarget, const std::string type) {
  NativeEventTarget* nativeEventTarget = new NativeEventTarget(eventTarget);
  auto nativeEventType = stringToNativeString(type);
  NativeEvent* nativeEvent = new NativeEvent();
  nativeEvent->type = nativeEventType.get();

  RawEvent rawEvent{reinterpret_cast<uint64_t*>(nativeEvent)};

  NativeEventTarget::dispatchEventImpl(nativeEventTarget, nativeEventType.get(), &rawEvent, false);
}
