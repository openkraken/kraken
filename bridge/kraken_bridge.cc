/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge.h"
#include <cassert>
#include "dart_methods.h"
#include "foundation/inspector_task_queue.h"
#include "foundation/logging.h"
#include "foundation/ui_task_queue.h"
#if KRAKEN_JSC_ENGINE
#include "bindings/jsc/KOM/performance.h"
#elif KRAKEN_QUICK_JS_ENGINE
#include "page.h"
#endif

#if KRAKEN_JSC_ENGINE
#include "bridge_jsc.h"
#endif

#include <atomic>
#include <thread>

#if defined(_WIN32)
#define SYSTEM_NAME "windows"  // Windows
#elif defined(_WIN64)
#define SYSTEM_NAME "windows"  // Windows
#elif defined(__CYGWIN__) && !defined(_WIN32)
#define SYSTEM_NAME "windows"  // Windows (Cygwin POSIX under Microsoft Window)
#elif defined(__ANDROID__)
#define SYSTEM_NAME "android"  // Android (implies Linux, so it must come first)
#elif defined(__linux__)
#define SYSTEM_NAME "linux"                    // Debian, Ubuntu, Gentoo, Fedora, openSUSE, RedHat, Centos and other
#elif defined(__APPLE__) && defined(__MACH__)  // Apple OSX and iOS (Darwin)
#include <TargetConditionals.h>
#if TARGET_IPHONE_SIMULATOR == 1
#define SYSTEM_NAME "ios"  // Apple iOS Simulator
#elif TARGET_OS_IPHONE == 1
#define SYSTEM_NAME "ios"  // Apple iOS
#elif TARGET_OS_MAC == 1
#define SYSTEM_NAME "macos"  // Apple macOS
#endif
#else
#define SYSTEM_NAME "unknown"
#endif

// this is not thread safe
std::atomic<bool> inited{false};
std::atomic<int32_t> poolIndex{0};
int maxPoolSize = 0;
kraken::KrakenPage** pageContextPool;
NativeScreen screen;

std::thread::id uiThreadId;

std::thread::id getUIThreadId() {
  return uiThreadId;
}

void printError(int32_t contextId, const char* errmsg) {
  if (kraken::getDartMethod()->onJsError != nullptr) {
    kraken::getDartMethod()->onJsError(contextId, errmsg);
  }
  KRAKEN_LOG(ERROR) << errmsg << std::endl;
}

namespace {

void disposeAllPages() {
  for (int i = 0; i <= poolIndex && i < maxPoolSize; i++) {
    disposePage(i);
  }
  poolIndex = 0;
  inited = false;
}

int32_t searchForAvailableContextId() {
  for (int i = 0; i < maxPoolSize; i++) {
    if (pageContextPool[i] == nullptr) {
      return i;
    }
  }
  return -1;
}

}  // namespace

void initJSPagePool(int poolSize) {
  uiThreadId = std::this_thread::get_id();
  // When dart hot restarted, should dispose previous bridge and clear task message queue.
  if (inited) {
    disposeAllPages();
  };
  pageContextPool = new kraken::KrakenPage*[poolSize];
  for (int i = 1; i < poolSize; i++) {
    pageContextPool[i] = nullptr;
  }

  pageContextPool[0] = new kraken::KrakenPage(0, printError);
  inited = true;
  maxPoolSize = poolSize;
}

void disposePage(int32_t contextId) {
  assert(contextId < maxPoolSize);
  if (pageContextPool[contextId] == nullptr)
    return;

  // In order to avoid accessing pageContextPool when the page is being released. We need to clear the value in pageContextPool before releasing.
  pageContextPool[contextId] = nullptr;

  // UnitTest will free page after test suit complete.
#ifndef UNIT_TEST
  auto* page = static_cast<kraken::KrakenPage*>(pageContextPool[contextId]);
  delete page;
#endif
}

int32_t allocateNewPage(int32_t targetContextId) {
  if (targetContextId == -1) {
    targetContextId = ++poolIndex;
  }

  if (targetContextId >= maxPoolSize) {
    targetContextId = searchForAvailableContextId();
  }

  assert(pageContextPool[targetContextId] == nullptr && (std::string("can not allocate page at index") + std::to_string(targetContextId) + std::string(": page have already exist.")).c_str());
  auto* page = new kraken::KrakenPage(targetContextId, printError);
  pageContextPool[targetContextId] = page;
  return targetContextId;
}

void* getPage(int32_t contextId) {
  assert(checkPage(contextId) && "getPage: contextId is not valid.");
  return pageContextPool[contextId];
}

bool checkPage(int32_t contextId) {
  return inited && contextId < maxPoolSize && pageContextPool[contextId] != nullptr;
}

bool checkPage(int32_t contextId, void* context) {
  if (pageContextPool[contextId] == nullptr)
    return false;
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  return page->getContext().get() == context;
}

void evaluateScripts(int32_t contextId, NativeString* code, const char* bundleFilename, int startLine) {
  assert(checkPage(contextId) && "evaluateScripts: contextId is not valid");
  auto context = static_cast<kraken::KrakenPage*>(getPage(contextId));
  context->evaluateScript(code, bundleFilename, startLine);
}

void evaluateQuickjsByteCode(int32_t contextId, uint8_t* bytes, int32_t byteLen) {
  assert(checkPage(contextId) && "evaluateScripts: contextId is not valid");
  auto context = static_cast<kraken::KrakenPage*>(getPage(contextId));
  context->evaluateByteCode(bytes, byteLen);
}

void parseHTML(int32_t contextId, const char* code, int32_t length) {
  assert(checkPage(contextId) && "parseHTML: contextId is not valid");
  auto context = static_cast<kraken::KrakenPage*>(getPage(contextId));
  context->parseHTML(code, length);
}

void reloadJsContext(int32_t contextId) {
  assert(checkPage(contextId) && "reloadJSContext: contextId is not valid");
  auto bridgePtr = getPage(contextId);
  auto context = static_cast<kraken::KrakenPage*>(bridgePtr);
  auto newContext = new kraken::KrakenPage(contextId, printError);
  delete context;
  pageContextPool[contextId] = newContext;
}

void invokeModuleEvent(int32_t contextId, NativeString* moduleName, const char* eventType, void* event, NativeString* extra) {
  assert(checkPage(contextId) && "invokeEventListener: contextId is not valid");
  auto context = static_cast<kraken::KrakenPage*>(getPage(contextId));
  context->invokeModuleEvent(moduleName, eventType, event, extra);
}

void registerDartMethods(uint64_t* methodBytes, int32_t length) {
  kraken::registerDartMethods(methodBytes, length);
}

NativeScreen* createScreen(double width, double height) {
  screen.width = width;
  screen.height = height;
  return &screen;
}

static KrakenInfo* krakenInfo{nullptr};

KrakenInfo* getKrakenInfo() {
  if (krakenInfo == nullptr) {
    krakenInfo = new KrakenInfo();
    krakenInfo->app_name = "Kraken";
    krakenInfo->app_revision = APP_REV;
    krakenInfo->app_version = APP_VERSION;
    krakenInfo->system_name = SYSTEM_NAME;
  }

  return krakenInfo;
}

void setConsoleMessageHandler(ConsoleMessageHandler handler) {
  kraken::KrakenPage::consoleMessageHandler = handler;
}

void dispatchUITask(int32_t contextId, void* context, void* callback) {
  assert(std::this_thread::get_id() == getUIThreadId());
  reinterpret_cast<void (*)(void*)>(callback)(context);
}

void flushUITask(int32_t contextId) {
  foundation::UITaskQueue::instance(contextId)->flushTask();
}

void registerUITask(int32_t contextId, Task task, void* data) {
  foundation::UITaskQueue::instance(contextId)->registerTask(task, data);
};

void flushUICommandCallback() {
  foundation::UICommandCallbackQueue::instance()->flushCallbacks();
}

UICommandItem* getUICommandItems(int32_t contextId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  return page->getContext()->uiCommandBuffer()->data();
}

int64_t getUICommandItemSize(int32_t contextId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  return page->getContext()->uiCommandBuffer()->size();
}

void clearUICommandItems(int32_t contextId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  page->getContext()->uiCommandBuffer()->clear();
}

void registerContextDisposedCallbacks(int32_t contextId, Task task, void* data) {
  assert(checkPage(contextId));
  auto context = static_cast<kraken::KrakenPage*>(getPage(contextId));
}

void registerPluginByteCode(uint8_t* bytes, int32_t length, const char* pluginName) {
  kraken::KrakenPage::pluginByteCode[pluginName] = NativeByteCode{bytes, length};
}

int32_t profileModeEnabled() {
#if ENABLE_PROFILE
  return 1;
#else
  return 0;
#endif
}

NativeString* NativeString::clone() {
  auto* newNativeString = new NativeString();
  auto* newString = new uint16_t[length];

  memcpy(newString, string, length * sizeof(uint16_t));
  newNativeString->string = newString;
  newNativeString->length = length;
  return newNativeString;
}

void NativeString::free() {
  delete[] string;
}
