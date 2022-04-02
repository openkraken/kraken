/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <sys/time.h>
#include <vector>

#include "core/dom/frame_request_callback_collection.h"
#include "core/frame/dom_timer.h"
#include "core/page.h"
#include "foundation/native_string.h"
#include "kraken_bridge_test.h"
#include "kraken_test_env.h"

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

namespace kraken {

typedef struct {
  struct list_head link;
  int64_t timeout;
  kraken::DOMTimer* timer;
  int32_t contextId;
  bool isInterval;
  AsyncCallback func;
} JSOSTimer;

typedef struct {
  struct list_head link;
  kraken::FrameCallback* callback;
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

NativeString* TEST_invokeModule(void* callbackContext,
                                int32_t contextId,
                                NativeString* moduleName,
                                NativeString* method,
                                NativeString* params,
                                AsyncModuleCallback callback) {
  std::string module = nativeStringToStdString(moduleName);

  if (module == "throwError") {
    callback(callbackContext, contextId, nativeStringToStdString(method).c_str(), nullptr);
  }

  if (module == "MethodChannel") {
    callback(callbackContext, contextId, nullptr, stringToNativeString("{\"result\": 1234}").release());
  }

  return stringToNativeString(module).release();
};

void TEST_requestBatchUpdate(int32_t contextId){};

void TEST_reloadApp(int32_t contextId) {}

int32_t timerId = 0;

int32_t TEST_setTimeout(kraken::DOMTimer* timer, int32_t contextId, AsyncCallback callback, int32_t timeout) {
  JSRuntime* rt = ScriptState::runtime();
  auto* context = timer->context();
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

int32_t TEST_setInterval(kraken::DOMTimer* timer, int32_t contextId, AsyncCallback callback, int32_t timeout) {
  JSRuntime* rt = ScriptState::runtime();
  auto* context = timer->context();
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

uint32_t TEST_requestAnimationFrame(kraken::FrameCallback* frameCallback, int32_t contextId, AsyncRAFCallback handler) {
  JSRuntime* rt = ScriptState::runtime();
  auto* context = frameCallback->context();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(rt));
  JSFrameCallback* th = static_cast<JSFrameCallback*>(js_mallocz(context->ctx(), sizeof(*th)));
  th->handler = handler;
  th->callback = frameCallback;
  th->contextId = context->contextId();
  int32_t id = callbackId++;

  th->callbackId = id;

  ts->os_frameCallbacks[id] = th;

  return id;
}

void TEST_cancelAnimationFrame(int32_t contextId, int32_t id) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  auto* context = page->getContext();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(ScriptState::runtime()));
  ts->os_frameCallbacks.erase(id);
}

void TEST_clearTimeout(int32_t contextId, int32_t timerId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  auto* context = page->getContext();
  JSThreadState* ts = static_cast<JSThreadState*>(JS_GetRuntimeOpaque(ScriptState::runtime()));
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

void TEST_toBlob(void* callbackContext,
                 int32_t contextId,
                 AsyncBlobCallback blobCallback,
                 int32_t elementId,
                 double devicePixelRatio) {}

void TEST_flushUICommand() {}

void TEST_initWindow(int32_t contextId, void* nativePtr) {}

void TEST_initDocument(int32_t contextId, void* nativePtr) {}

#if ENABLE_PROFILE
NativePerformanceEntryList* TEST_getPerformanceEntries(int32_t) {
  return nullptr;
}
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
    initJSPagePool(1024 * 1024);
    inited = true;
  });
  initTestFramework(contextId);
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  auto* context = page->getContext();
  JSThreadState* th = new JSThreadState();
  JS_SetRuntimeOpaque(ScriptState::runtime(), th);

  TEST_mockDartMethods(contextId, onJsError);

  return std::unique_ptr<kraken::KrakenPage>(page);
}

std::unique_ptr<kraken::KrakenPage> TEST_init() {
  return TEST_init(nullptr);
}

std::unique_ptr<kraken::KrakenPage> TEST_allocateNewPage() {
  uint32_t newContextId = allocateNewPage(-1);
  initTestFramework(newContextId);
  return std::unique_ptr<kraken::KrakenPage>(static_cast<kraken::KrakenPage*>(getPage(newContextId)));
}

static bool jsPool(kraken::ExecutingContext* context) {
  JSRuntime* rt = ScriptState::runtime();
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

void TEST_runLoop(kraken::ExecutingContext* context) {
  for (;;) {
    context->DrainPendingPromiseJobs();
    if (jsPool(context))
      break;
  }
}

void TEST_mockDartMethods(int32_t contextId, OnJSError onJSError) {
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
  mockMethods.emplace_back(reinterpret_cast<uint64_t>(TEST_getPerformanceEntries));
#else
  mockMethods.emplace_back(0);
#endif

  mockMethods.emplace_back(reinterpret_cast<uint64_t>(onJSError));
  registerDartMethods(contextId, mockMethods.data(), mockMethods.size());
}

}  // namespace kraken

// void TEST_dispatchEvent(int32_t contextId, EventTarget* eventTarget, const std::string type) {
//  NativeEventTarget* nativeEventTarget = new NativeEventTarget(eventTarget);
//  auto nativeEventType = stringToNativeString(type);
//  NativeString* rawEventType = nativeEventType.release();
//
//  NativeEvent* nativeEvent = new NativeEvent{rawEventType};
//
//  RawEvent* rawEvent = new RawEvent{reinterpret_cast<uint64_t*>(nativeEvent)};
//
//  NativeEventTarget::dispatchEventImpl(contextId, nativeEventTarget, rawEventType, rawEvent, false);
//}
//
// void TEST_callNativeMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv) {}
//
// std::unordered_map<int32_t, std::shared_ptr<UnitTestEnv>> unitTestEnvMap;
// std::shared_ptr<UnitTestEnv> TEST_getEnv(int32_t contextUniqueId) {
//  if (unitTestEnvMap.count(contextUniqueId) == 0) {
//    unitTestEnvMap[contextUniqueId] = std::make_shared<UnitTestEnv>();
//  }
//
//  return unitTestEnvMap[contextUniqueId];
//}
//
// void TEST_registerEventTargetDisposedCallback(int32_t contextUniqueId, TEST_OnEventTargetDisposed callback) {
//  if (unitTestEnvMap.count(contextUniqueId) == 0) {
//    unitTestEnvMap[contextUniqueId] = std::make_shared<UnitTestEnv>();
//  }
//
//  unitTestEnvMap[contextUniqueId]->onEventTargetDisposed = callback;
//}
