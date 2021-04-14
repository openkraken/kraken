/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge.h"
#include "dart_methods.h"
#include "foundation/logging.h"
#include "foundation/ui_task_queue.h"
#include "foundation/inspector_task_queue.h"

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
std::atomic<int32_t> poolIndex{0};
int maxPoolSize = 0;
kraken::JSBridge **contextPool;
Screen screen;

std::__thread_id uiThreadId;

std::__thread_id getUIThreadId() {
  return uiThreadId;
}

void printError(int32_t contextId, const char* errmsg) {
  if (kraken::getDartMethod()->onJsError != nullptr) {
    kraken::getDartMethod()->onJsError(contextId, errmsg);
  }
  KRAKEN_LOG(ERROR) << errmsg << std::endl;
}

namespace {

void disposeAllBridge() {
  for (int i = 0; i <= poolIndex; i++) {
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

void initJSContextPool(int poolSize) {
  uiThreadId = std::this_thread::get_id();
  // When dart hot restarted, should dispose previous bridge and clear task message queue.
  if (inited) {
    disposeAllBridge();
    foundation::UICommandTaskMessageQueue::instance(0)->clear();
  };
  contextPool = new kraken::JSBridge *[poolSize];
  for (int i = 1; i < poolSize; i++) {
    contextPool[i] = nullptr;
  }

  contextPool[0] = new kraken::JSBridge(0, printError);
  inited = true;
  maxPoolSize = poolSize;
}

void disposeContext(int32_t contextId) {
  assert(contextId < maxPoolSize);
  if (contextPool[contextId] == nullptr) return;
  auto context = static_cast<kraken::JSBridge *>(contextPool[contextId]);
  delete context;
  contextPool[contextId] = nullptr;
}

int32_t allocateNewContext() {
  poolIndex++;
  if (poolIndex >= maxPoolSize) {
    poolIndex = searchForAvailableContextId();
  }

  assert(contextPool[poolIndex] == nullptr && (std::string("can not allocate JSBridge at index") +
                                               std::to_string(poolIndex) + std::string(": bridge have already exist."))
                                                .c_str());

  auto context = new kraken::JSBridge(poolIndex, printError);
  contextPool[poolIndex] = context;
  return poolIndex;
}

void *getJSContext(int32_t contextId) {
  assert(checkContext(contextId) && "getJSContext: contextId is not valid.");
  return contextPool[contextId];
}

bool checkContext(int32_t contextId) {
  return inited && contextId < maxPoolSize && contextPool[contextId] != nullptr;
}

bool checkContext(int32_t contextId, void *context) {
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
  assert(checkContext(contextId) && "reloadJSContext: contextId is not valid");
  auto bridgePtr = getJSContext(contextId);
  auto context = static_cast<kraken::JSBridge *>(bridgePtr);
  auto newContext = new kraken::JSBridge(contextId, printError);
  delete context;
  contextPool[contextId] = newContext;
}

void invokeModuleEvent(int32_t contextId, NativeString *moduleName, const char *eventType, void *event, NativeString *extra) {
  assert(checkContext(contextId) && "invokeEventListener: contextId is not valid");
  auto context = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  context->invokeModuleEvent(moduleName, eventType, event, extra);
}

void registerDartMethods(uint64_t *methodBytes, int32_t length) {
  kraken::registerDartMethods(methodBytes, length);
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

void dispatchUITask(int32_t contextId, int32_t taskId) {
  foundation::UITaskQueue::instance(contextId)->dispatchTask(taskId);
}

UICommandItem *getUICommandItems(int32_t contextId) {
  return foundation::UICommandTaskMessageQueue::instance(contextId)->data();
}

int64_t getUICommandItemSize(int32_t contextId) {
  return foundation::UICommandTaskMessageQueue::instance(contextId)->size();
}

void clearUICommandItems(int32_t contextId) {
  return foundation::UICommandTaskMessageQueue::instance(contextId)->clear();
}

void flushUICommandCallback() {
  foundation::UICommandCallbackQueue::instance()->flushCallbacks();
}

void registerPluginSource(NativeString *code, const char *pluginName) {
  kraken::JSBridge::pluginSourceCode[pluginName] = NativeString{
    code->string,
    code->length
  };
}

#if ENABLE_DEBUGGER
std::__thread_id inspectorThreadId;
void attachInspector(int32_t contextId) {
  inspectorThreadId = std::this_thread::get_id();
  KRAKEN_LOG(VERBOSE) << "inspector thread id " << inspectorThreadId;
  assert(checkContext(contextId));
  auto context = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  context->attachInspector();
}
void registerInspectorDartMethods(uint64_t *methodBytes, int32_t length) {
  kraken::registerInspectorDartMethods(methodBytes, length);
}
void dispatchInspectorTask(int32_t contextId, int32_t taskId) {
  foundation::InspectorTaskQueue::instance(contextId)->dispatchTask(taskId);
}
std::__thread_id getInspectorThreadId() {
  return inspectorThreadId;
}
#endif

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
