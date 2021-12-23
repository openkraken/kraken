/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_test_env.h"
#include <sys/time.h>
#include <vector>
#include "bindings/qjs/dom/event_target.h"
#include "dart_methods.h"
#include "include/kraken_bridge.h"
#include "kraken_bridge_test.h"
#include "page.h"

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

NativeString* TEST_invokeModule(void* callbackContext, int32_t contextId, NativeString* moduleName, NativeString* method, NativeString* params, AsyncModuleCallback callback) {
  return nullptr;
};

void TEST_requestBatchUpdate(int32_t contextId){};

void TEST_reloadApp(int32_t contextId) {}

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

uint32_t TEST_requestAnimationFrame(FrameCallback* frameCallback, int32_t contextId, AsyncRAFCallback handler) {
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

void TEST_cancelAnimationFrame(int32_t contextId, int32_t id) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  auto* context = page->getContext().get();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(context->runtime()));
  ts->os_frameCallbacks.erase(id);
}

void TEST_clearTimeout(int32_t contextId, int32_t timerId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  auto* context = page->getContext().get();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(context->runtime()));
  ts->os_timers.erase(timerId);
}

NativeScreen* TEST_getScreen(int32_t contextId) {
  return nullptr;
};

double TEST_devicePixelRatio(int32_t contextId) {
  return 1.0;
}

NativeString* TEST_platformBrightness(int32_t contextId) {
  return nullptr;
}

void TEST_toBlob(void* callbackContext, int32_t contextId, AsyncBlobCallback blobCallback, int32_t elementId, double devicePixelRatio) {}

void TEST_flushUICommand() {}

void TEST_initWindow(int32_t contextId, void* nativePtr) {}

void TEST_initDocument(int32_t contextId, void* nativePtr) {}

#if ENABLE_PROFILE
struct NativePerformanceEntryList {
  uint64_t* entries;
  int32_t length;
};
NativePerformanceEntryList* TEST_getPerformanceEntries(int32_t) {}
#endif

std::once_flag testInitOnceFlag;
static int32_t inited{false};

std::unique_ptr<kraken::KrakenPage> TEST_init(OnJSError onJsError) {
  uint32_t contextId;
  if (inited) {
    contextId = allocateNewPage(-1);
  } else {
    contextId = 0;
  }
  std::call_once(testInitOnceFlag, []() {
    initJSPagePool(1024);
    inited = true;
  });
  initTestFramework(contextId);
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  auto* context = page->getContext().get();
  JSThreadState* th = new JSThreadState();
  JS_SetRuntimeOpaque(context->runtime(), th);

  std::vector<uint64_t> mockMethods{
      reinterpret_cast<uint64_t>(TEST_invokeModule),
      reinterpret_cast<uint64_t>(TEST_requestBatchUpdate),
      reinterpret_cast<uint64_t>(TEST_reloadApp),
      reinterpret_cast<uint64_t>(TEST_setTimeout),
      reinterpret_cast<uint64_t>(TEST_setInterval),
      reinterpret_cast<uint64_t>(TEST_clearTimeout),
      reinterpret_cast<uint64_t>(TEST_requestAnimationFrame),
      reinterpret_cast<uint64_t>(TEST_cancelAnimationFrame),
      reinterpret_cast<uint64_t>(TEST_getScreen),
      reinterpret_cast<uint64_t>(TEST_devicePixelRatio),
      reinterpret_cast<uint64_t>(TEST_platformBrightness),
      reinterpret_cast<uint64_t>(TEST_toBlob),
      reinterpret_cast<uint64_t>(TEST_flushUICommand),
      reinterpret_cast<uint64_t>(TEST_initWindow),
      reinterpret_cast<uint64_t>(TEST_initDocument),
  };

#if ENABLE_PROFILE
  mockMethods.emplace_pack(reinterpret_cast<uint64_t>(TEST_getPerformanceEntries));
#else
  mockMethods.emplace_back(0);
#endif

  mockMethods.emplace_back(reinterpret_cast<uint64_t>(onJsError));
  registerDartMethods(mockMethods.data(), mockMethods.size());

  return std::unique_ptr<kraken::KrakenPage>(page);
}

std::unique_ptr<kraken::KrakenPage> TEST_init() {
  return TEST_init(nullptr);
}

std::unique_ptr<kraken::KrakenPage> TEST_allocateNewPage() {
  uint32_t newContextId = allocateNewPage(-1);
  return std::unique_ptr<kraken::KrakenPage>(static_cast<kraken::KrakenPage*>(getPage(newContextId)));
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

void TEST_callNativeMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv) {}
