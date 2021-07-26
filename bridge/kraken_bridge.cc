/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge.h"
#include "dart_methods.h"
#include "foundation/logging.h"
#include "foundation/ui_task_queue.h"
#include "foundation/inspector_task_queue.h"
#include "bindings/jsc/KOM/performance.h"

#ifdef KRAKEN_ENABLE_JSA
#include "bridge_jsa.h"
#elif KRAKEN_JSC_ENGINE
#include "bridge_jsc.h"
#endif

#include <atomic>
#include <thread>

#if defined(_WIN32)
#define SYSTEM_NAME "windows" // Windows
#elif defined(_WIN64)
#define SYSTEM_NAME "windows" // Windows
#elif defined(__CYGWIN__) && !defined(_WIN32)
#define SYSTEM_NAME "windows" // Windows (Cygwin POSIX under Microsoft Window)
#elif defined(__ANDROID__)
#define SYSTEM_NAME "android" // Android (implies Linux, so it must come first)
#elif defined(__linux__)
#define SYSTEM_NAME "linux"                      // Debian, Ubuntu, Gentoo, Fedora, openSUSE, RedHat, Centos and other
#elif defined(__APPLE__) && defined(__MACH__) // Apple OSX and iOS (Darwin)
#include <TargetConditionals.h>
#if TARGET_IPHONE_SIMULATOR == 1
#define SYSTEM_NAME "ios" // Apple iOS Simulator
#elif TARGET_OS_IPHONE == 1
#define SYSTEM_NAME "ios" // Apple iOS
#elif TARGET_OS_MAC == 1
#define SYSTEM_NAME "macos" // Apple macOS
#endif
#else
#define SYSTEM_NAME "unknown"
#endif

// this is not thread safe
std::atomic<bool> inited{false};
std::atomic<int32_t> poolIndex{-1};
int maxPoolSize = 0;
kraken::JSBridge **contextPool;
Screen screen;
std::recursive_mutex bridge_runtime_mutex_;

std::__thread_id uiThreadId;

std::__thread_id getUIThreadId() {
  return uiThreadId;
}

void printError(int32_t contextId, const char* errmsg) {
    kraken::JSBridge* bridge = static_cast<kraken::JSBridge* >(getJSContext(contextId));
  if (kraken::getDartMethod(bridge)->onJsError != nullptr) {
    kraken::getDartMethod(bridge)->onJsError(contextId, errmsg);
  }
  KRAKEN_LOG(ERROR) << errmsg << std::endl;
}

namespace {

void disposeAllBridge() {
    if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
        KRAKEN_LOG(VERBOSE) << "disposeAllBridge" << std::endl;
    }
    for (int i = 0; i <= poolIndex && i < maxPoolSize; i++) {
        disposeContext(i);
    }
  poolIndex = 0;
  inited = false;
}

int32_t searchForAvailableContextId() {
  for (int i = 0; i < maxPoolSize; i++) {
    if (contextPool[i] == nullptr) {
      return i;
    }
  }
  return -1;
}

} // namespace

int32_t initJSContextPool(int32_t isolateHash, int poolSize) {
    std::lock_guard<std::recursive_mutex> guard(bridge_runtime_mutex_);
    uiThreadId = std::this_thread::get_id();
    if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
        KRAKEN_LOG(VERBOSE) << "initJSContextPool" << inited << std::endl;
        KRAKEN_LOG(VERBOSE) << "initJSContextPool isolateHash::--> " << isolateHash << std::endl;
        KRAKEN_LOG(VERBOSE) << "initJSContextPool uiThreadId::--> " << uiThreadId << std::endl;
    }
    // When dart hot restarted, should dispose previous bridge and clear task message queue.
    if (!inited) {
//        if (inited) {
//            disposeAllBridge();
//            foundation::UICommandBuffer::instance(0)->isolateHash = isolateHash;
//            foundation::UICommandBuffer::instance(0)->clear();
//        };
        contextPool = new kraken::JSBridge *[poolSize];
        for (int i = 1; i < poolSize; i++) {
            contextPool[i] = nullptr;
        }

        inited = true;
        maxPoolSize = poolSize;
    }

    poolIndex++;
      contextPool[poolIndex] = new kraken::JSBridge(isolateHash, poolIndex, printError);
    return poolIndex;
}

void disposeContext(int32_t contextId) {
    std::lock_guard<std::recursive_mutex> guard(bridge_runtime_mutex_);
    if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
        KRAKEN_LOG(VERBOSE) << "disposeContext" << contextId << std::endl;
    }
    assert(contextId < maxPoolSize);
  if (contextPool[contextId] == nullptr) return;
  auto context = static_cast<kraken::JSBridge *>(contextPool[contextId]);
  delete context;
  contextPool[contextId] = nullptr;
#if ENABLE_PROFILE
  auto nativePerformance = kraken::binding::jsc::NativePerformance::instance(contextId);
  nativePerformance->entries.clear();
#endif
}

int32_t allocateNewContext(int32_t isolateHash, int32_t targetContextId) {
  if (targetContextId == -1) {
    targetContextId = ++poolIndex;
  }

  if (targetContextId >= maxPoolSize) {
    targetContextId = searchForAvailableContextId();
  }

  assert(contextPool[targetContextId] == nullptr && (std::string("can not allocate JSBridge at index") +
                                               std::to_string(targetContextId) + std::string(": bridge have already exist."))
                                                .c_str());

  auto context = new kraken::JSBridge(isolateHash, targetContextId, printError);
    foundation::UICommandBuffer::instance(targetContextId)->isolateHash = isolateHash;
    contextPool[targetContextId] = context;
  return targetContextId;
}

void *getJSContext(int32_t contextId) {
    std::lock_guard<std::recursive_mutex> guard(bridge_runtime_mutex_);
    if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
        KRAKEN_LOG(VERBOSE) << "getJSContext:: contextId " << contextId << std::endl;
        KRAKEN_LOG(VERBOSE) << "getJSContext:: contextPool[contextId] " << contextPool[contextId] << std::endl;
    }
    kraken::JSBridge* bridge = static_cast<kraken::JSBridge* >(contextPool[contextId]);

//    assert(checkContext(contextId) && "getJSContext: contextId is not valid.");
  return contextPool[contextId];
}

bool checkContext(int32_t contextId) {
    std::lock_guard<std::recursive_mutex> guard(bridge_runtime_mutex_);
    return inited && contextId < maxPoolSize && contextPool[contextId] != nullptr;
}

bool checkContext(int32_t contextId, void *context) {
    std::lock_guard<std::recursive_mutex> guard(bridge_runtime_mutex_);
    if (contextPool[contextId] == nullptr) return false;
  auto bridge = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  return bridge->getContext().get() == context;
}

void evaluateScripts(int32_t contextId, NativeString *code, const char *bundleFilename, int startLine) {
  assert(checkContext(contextId) && "evaluateScripts: contextId is not valid");
  auto context = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  context->evaluateScript(code, bundleFilename, startLine);
}

void reloadJsContext(int32_t contextId) {
    std::lock_guard<std::recursive_mutex> guard(bridge_runtime_mutex_);
    assert(checkContext(contextId) && "reloadJSContext: contextId is not valid");
  auto bridgePtr = getJSContext(contextId);
  auto context = static_cast<kraken::JSBridge *>(bridgePtr);
  auto newContext = new kraken::JSBridge(context->isolateHash, contextId, printError);
  delete context;
  contextPool[contextId] = newContext;
}

void invokeModuleEvent(int32_t contextId, NativeString *moduleName, const char *eventType, void *event, NativeString *extra) {
  assert(checkContext(contextId) && "invokeEventListener: contextId is not valid");
  auto context = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  context->invokeModuleEvent(moduleName, eventType, event, extra);
}

void registerDartMethods(int32_t isolateHash, uint64_t *methodBytes, int32_t length) {
  kraken::registerDartMethods(isolateHash, methodBytes, length);
}

Screen *createScreen(double width, double height) {
  screen.width = width;
  screen.height = height;
  return &screen;
}

static KrakenInfo *krakenInfo{nullptr};

const char *getUserAgent(KrakenInfo *info) {
  const char *format = "%s/%s (%s; %s/%s)";
  int32_t length = strlen(format) + sizeof(*info);
  char *buf = new char[length];
  std::string result;
  std::snprintf(&buf[0], length, format, info->app_name, info->app_version, info->system_name, info->app_name, info->app_revision);
  return buf;
}

KrakenInfo *getKrakenInfo() {
  if (krakenInfo == nullptr) {
    krakenInfo = new KrakenInfo();
    krakenInfo->app_name = "Kraken";
    krakenInfo->app_revision = APP_REV;
    krakenInfo->app_version = APP_VERSION;
    krakenInfo->system_name = SYSTEM_NAME;
    krakenInfo->getUserAgent = getUserAgent;
  }

  return krakenInfo;
}

void setConsoleMessageHandler(ConsoleMessageHandler handler) {
  kraken::JSBridge::consoleMessageHandler = handler;
}

void dispatchUITask(int32_t contextId, void *context, void *callback) {
  assert(std::this_thread::get_id() == getUIThreadId());
  reinterpret_cast<void(*)(void*)>(callback)(context);
}

void flushUITask(int32_t contextId) {
  foundation::UITaskQueue::instance(contextId)->flushTask();
}

void registerUITask(int32_t contextId, Task task, void *data) {
  foundation::UITaskQueue::instance(contextId)->registerTask(task, data);
};

void flushUICommandCallback() {
  foundation::UICommandCallbackQueue::instance()->flushCallbacks();
}

UICommandItem *getUICommandItems(int32_t contextId) {
  return foundation::UICommandBuffer::instance(contextId)->data();
}

int64_t getUICommandItemSize(int32_t contextId) {
  return foundation::UICommandBuffer::instance(contextId)->size();
}

void clearUICommandItems(int32_t contextId) {
  return foundation::UICommandBuffer::instance(contextId)->clear();
}

void registerContextDisposedCallbacks(int32_t contextId, Task task, void *data) {
  assert(checkContext(contextId));
  auto context = static_cast<kraken::JSBridge *>(getJSContext(contextId));

}

void registerPluginSource(NativeString *code, const char *pluginName) {
  kraken::JSBridge::pluginSourceCode[pluginName] = NativeString{
    code->string,
    code->length
  };
}

NativeString *NativeString::clone() {
  NativeString *newNativeString = new NativeString();
  uint16_t *newString = new uint16_t[length];

  for (size_t i = 0; i < length; i++) {
    newString[i] = string[i];
  }

  newNativeString->string = newString;
  newNativeString->length = length;
  return newNativeString;
}

void NativeString::free() {
  delete[] string;
  delete this;
}
