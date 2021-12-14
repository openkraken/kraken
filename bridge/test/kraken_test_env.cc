/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_test_env.h"
#include <vector>
#include <sys/time.h>

#if defined(__linux__) || defined(__APPLE__)
static int64_t get_time_ms(void)
{
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (uint64_t)ts.tv_sec * 1000 + (ts.tv_nsec / 1000000);
}
#else
/* more portable, but does not work if the date is updated */
static int64_t get_time_ms(void)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (int64_t)tv.tv_sec * 1000 + (tv.tv_usec / 1000);
}
#endif

typedef struct {
  struct list_head link;
  int64_t timeout;
  void *callbackContext;
  int32_t contextId;
  AsyncCallback func;
} JSOSTimer;

typedef struct JSThreadState {
  struct list_head os_timers; /* list of timer.link */
} JSThreadState;

static void unlink_timer(JSRuntime *rt, JSOSTimer *th)
{
  if (th->link.prev) {
    list_del(&th->link);
    th->link.prev = th->link.next = NULL;
  }
}

void TEST_init(PageJSContext *context) {
  JSThreadState *th = new JSThreadState();
  init_list_head(&th->os_timers);
  JS_SetRuntimeOpaque(context->runtime(), th);
}

int32_t TEST_setTimeout(DOMTimerCallbackContext *callbackContext, int32_t contextId, AsyncCallback callback, int32_t timeout) {
  JSRuntime *rt = JS_GetRuntime(callbackContext->context->ctx());
  JSThreadState *ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  JSOSTimer *th = static_cast<JSOSTimer*>(js_mallocz(callbackContext->context->ctx(), sizeof(*th)));
  th->timeout = get_time_ms() + timeout;
  th->func = callback;
  th->callbackContext = callbackContext;
  th->contextId = contextId;
  list_add_tail(&th->link, &ts->os_timers);

  return 0;
}

static bool jsPool(PageJSContext *context) {
  JSRuntime *rt = context->runtime();
  JSThreadState *ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  int64_t cur_time, delay;
  struct list_head *el;

  if (list_empty(&ts->os_timers))
    return true; /* no more events */

  if (!list_empty(&ts->os_timers)) {
    cur_time = get_time_ms();
    list_for_each(el, &ts->os_timers) {
      JSOSTimer *th = list_entry(el, JSOSTimer, link);
      delay = th->timeout - cur_time;
      if (delay <= 0) {
        AsyncCallback func;
        /* the timer expired */
        func = th->func;
        th->func = nullptr;
        unlink_timer(rt, th);
        func(th->callbackContext, th->contextId, nullptr);
        return false;
      }
    }
  }

  return false;
}

void TEST_runLoop(PageJSContext *context) {
  for(;;) {
    context->drainPendingPromiseJobs();
    if (jsPool(context)) break;
  }
}
