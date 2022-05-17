/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

#include <atomic>
#include <cassert>
#include <thread>

#include "bindings/qjs/native_string_utils.h"
#include "core/page.h"
#include "foundation/inspector_task_queue.h"
#include "foundation/logging.h"
#include "foundation/ui_command_buffer.h"
#include "foundation/ui_task_queue.h"
#include "include/kraken_bridge.h"

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
    if (kraken::KrakenPage::pageContextPool[i] == nullptr) {
      return i;
    }
  }
  return -1;
}

}  // namespace

void initJSPagePool(int poolSize) {
  // When dart hot restarted, should dispose previous bridge and clear task message queue.
  if (inited) {
    disposeAllPages();
  };
  kraken::KrakenPage::pageContextPool = new kraken::KrakenPage*[poolSize];
  for (int i = 1; i < poolSize; i++) {
    kraken::KrakenPage::pageContextPool[i] = nullptr;
  }

  kraken::KrakenPage::pageContextPool[0] = new kraken::KrakenPage(0, nullptr);
  inited = true;
  maxPoolSize = poolSize;
}

void disposePage(int32_t contextId) {
  assert(contextId < maxPoolSize);
  if (kraken::KrakenPage::pageContextPool[contextId] == nullptr)
    return;

  auto* page = static_cast<kraken::KrakenPage*>(kraken::KrakenPage::pageContextPool[contextId]);
  delete page;
  kraken::KrakenPage::pageContextPool[contextId] = nullptr;
}

int32_t allocateNewPage(int32_t targetContextId) {
  if (targetContextId == -1) {
    targetContextId = ++poolIndex;
  }

  if (targetContextId >= maxPoolSize) {
    targetContextId = searchForAvailableContextId();
  }

  assert(kraken::KrakenPage::pageContextPool[targetContextId] == nullptr &&
         (std::string("can not Allocate page at index") + std::to_string(targetContextId) +
          std::string(": page have already exist."))
             .c_str());
  auto* page = new kraken::KrakenPage(targetContextId, nullptr);
  kraken::KrakenPage::pageContextPool[targetContextId] = page;
  return targetContextId;
}

void* getPage(int32_t contextId) {
  if (!checkPage(contextId))
    return nullptr;
  return kraken::KrakenPage::pageContextPool[contextId];
}

bool checkPage(int32_t contextId) {
  return inited && contextId < maxPoolSize && kraken::KrakenPage::pageContextPool[contextId] != nullptr;
}

bool checkPage(int32_t contextId, void* context) {
  if (kraken::KrakenPage::pageContextPool[contextId] == nullptr)
    return false;
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  return page->GetExecutingContext() == context;
}

void evaluateScripts(int32_t contextId, NativeString* code, const char* bundleFilename, int startLine) {
  assert(checkPage(contextId) && "evaluateScripts: contextId is not valid");
  auto context = static_cast<kraken::KrakenPage*>(getPage(contextId));
  context->evaluateScript(reinterpret_cast<kraken::NativeString*>(code), bundleFilename, startLine);
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
  auto newContext = new kraken::KrakenPage(contextId, nullptr);
  delete context;
  kraken::KrakenPage::pageContextPool[contextId] = newContext;
}

void invokeModuleEvent(int32_t contextId,
                       NativeString* moduleName,
                       const char* eventType,
                       void* event,
                       NativeString* extra) {
  assert(checkPage(contextId) && "invokeEventListener: contextId is not valid");
  auto context = static_cast<kraken::KrakenPage*>(getPage(contextId));
  context->invokeModuleEvent(reinterpret_cast<kraken::NativeString*>(moduleName), eventType, event, reinterpret_cast<kraken::NativeString*>(extra));
}

void registerDartMethods(int32_t contextId, uint64_t* methodBytes, int32_t length) {
  assert(checkPage(contextId) && "registerDartMethods: contextId is not valid");
  auto context = static_cast<kraken::KrakenPage*>(getPage(contextId));
  context->registerDartMethods(methodBytes, length);
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
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  assert(std::this_thread::get_id() == page->currentThread());
  reinterpret_cast<void (*)(void*)>(callback)(context);
}

void flushUITask(int32_t contextId) {
  kraken::UITaskQueue::instance(contextId)->flushTask();
}

void registerUITask(int32_t contextId, Task task, void* data) {
  kraken::UITaskQueue::instance(contextId)->registerTask(task, data);
};

void* getUICommandItems(int32_t contextId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  if (page == nullptr)
    return nullptr;
  return page->GetExecutingContext()->uiCommandBuffer()->data();
}

int64_t getUICommandItemSize(int32_t contextId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  if (page == nullptr)
    return 0;
  return page->GetExecutingContext()->uiCommandBuffer()->size();
}

void clearUICommandItems(int32_t contextId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  if (page == nullptr)
    return;
  page->GetExecutingContext()->uiCommandBuffer()->clear();
}

void registerContextDisposedCallbacks(int32_t contextId, Task task, void* data) {
  assert(checkPage(contextId));
  auto context = static_cast<kraken::KrakenPage*>(getPage(contextId));
}

void registerPluginByteCode(uint8_t* bytes, int32_t length, const char* pluginName) {
  kraken::ExecutingContext::pluginByteCode[pluginName] = kraken::NativeByteCode{bytes, length};
}

int32_t profileModeEnabled() {
#if ENABLE_PROFILE
  return 1;
#else
  return 0;
#endif
}
