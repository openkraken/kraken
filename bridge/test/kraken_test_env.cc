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
  AsyncCallback func;
} JSOSTimer;

typedef struct JSThreadState {
  std::unordered_map<int32_t, JSOSTimer*> os_timers; /* list of timer.link */
} JSThreadState;

static void unlink_timer(JSThreadState* ts, JSOSTimer* th) {
  ts->os_timers.erase(th->timer->timerId());
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
  int32_t id = timerId++;

  ts->os_timers[id] = th;

  return id;
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

  if (ts->os_timers.empty())
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
        th->func = nullptr;
        func(th->timer, th->contextId, nullptr);
        unlink_timer(ts, th);
        return false;
      }
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
