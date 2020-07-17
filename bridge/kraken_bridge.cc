/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge.h"
#include "bridge.h"
#include "dart_methods.h"
#include "foundation/logging.h"
#include "jsa.h"

#include <atomic>

// this is not thread safe
std::atomic<bool> inited{false};
std::atomic<int32_t> poolIndex{0};
int maxPoolSize = 0;
kraken::JSBridge **contextPool;
Screen screen;

void printError(alibaba::jsa::JSContext &bridge, const alibaba::jsa::JSError &error) {
  if (kraken::getDartMethod()->onJsError != nullptr) {
    kraken::getDartMethod()->onJsError(bridge.getContextId(), error.what());
  } else {
    KRAKEN_LOG(ERROR) << error.what() << std::endl;
  }
}

namespace {

void disposeAllBridge() {
  for (int i = 0; i <= poolIndex; i++) {
    disposeContext(i);
  }
  poolIndex = 0;
  inited = false;
}

int32_t searchForAvailablecontextId() {
  for (int i = 0; i < maxPoolSize; i ++) {
    if (contextPool[i] == nullptr) {
      return i;
    }
  }
  return -1;
}

} // namespace

void initJSContextPool(int poolSize) {
  if (inited) disposeAllBridge();
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
  assert(contextPool[contextId] != nullptr);
  auto context = static_cast<kraken::JSBridge *>(contextPool[contextId]);
  delete context;
  contextPool[contextId] = nullptr;
}

int32_t allocateNewContext() {
  poolIndex++;
  if (poolIndex >= maxPoolSize) {
    return searchForAvailablecontextId();
  }

  assert(contextPool[poolIndex] == nullptr && (std::string("can not allocate JSBridge at index") +
                                             std::to_string(poolIndex) + std::string(": bridge have already exist."))
                                              .c_str());

  auto context = new kraken::JSBridge(poolIndex, printError);
  contextPool[poolIndex] = context;
  return poolIndex;
}

void *getJSContext(int32_t contextId) {
  assert(checkcontextId(contextId) && "getJSContext: contextId is not valid.");
  return contextPool[contextId];
}

int32_t checkcontextId(int32_t contextId) {
  return contextId < maxPoolSize && contextPool[contextId] != nullptr;
}

void freezeContext(int32_t contextId) {
  auto bridge = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  bridge->getContext()->freeze();
}

void unfreezeContext(int32_t contextId) {
  auto bridge = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  bridge->getContext()->unfreeze();
}

bool isContextFreeze(int32_t contextId) {
  auto bridge = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  return bridge->getContext()->isFreeze();
}

void evaluateScripts(int32_t contextId, const char *code, const char *bundleFilename,
                     int startLine) {
  assert(checkcontextId(contextId) && "evaluateScripts: contextId is not valid");
  auto context = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  context->evaluateScript(std::string(code), std::string(bundleFilename), startLine);
}

void reloadJsContext(int32_t contextId) {
  assert(checkcontextId(contextId) && "reloadJSContext: contextId is not valid");
  auto bridgePtr = getJSContext(contextId);
  if (isContextFreeze(contextId)) return;
  auto context = static_cast<kraken::JSBridge *>(bridgePtr);
  delete context;
  context = new kraken::JSBridge(contextId, printError);
  contextPool[contextId] = context;
}

void invokeEventListener(int32_t contextId, int32_t type, const char *data) {
  assert(checkcontextId(contextId) && "invokeEventListener: contextId is not valid");
  if (isContextFreeze(contextId)) return;
  auto context = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  context->invokeEventListener(type, data);
}

void registerInvokeUIManager(InvokeUIManager callbacks) {
  kraken::registerInvokeUIManager(callbacks);
}

void registerInvokeModule(InvokeModule callbacks) {
  kraken::registerInvokeModule(callbacks);
}

void registerRequestBatchUpdate(RequestBatchUpdate requestBatchUpdate) {
  kraken::registerRequestBatchUpdate(requestBatchUpdate);
}

void registerReloadApp(ReloadApp reloadApp) {
  kraken::registerReloadApp(reloadApp);
}

void registerSetTimeout(SetTimeout setTimeout) {
  kraken::registerSetTimeout(setTimeout);
}

void registerSetInterval(SetInterval setInterval) {
  kraken::registerSetInterval(setInterval);
}

void registerClearTimeout(ClearTimeout clearTimeout) {
  kraken::registerClearTimeout(clearTimeout);
}

void registerRequestAnimationFrame(RequestAnimationFrame requestAnimationFrame) {
  kraken::registerRequestAnimationFrame(requestAnimationFrame);
}

void registerCancelAnimationFrame(CancelAnimationFrame cancelAnimationFrame) {
  kraken::registerCancelAnimationFrame(cancelAnimationFrame);
}

void registerGetScreen(GetScreen getScreen) {
  kraken::registerGetScreen(getScreen);
}

void registerDevicePixelRatio(DevicePixelRatio devicePixelRatio) {
  kraken::registerDevicePixelRatio(devicePixelRatio);
}

void registerPlatformBrightness(PlatformBrightness platformBrightness) {
  kraken::registerPlatformBrightness(platformBrightness);
}

void registerOnPlatformBrightnessChanged(OnPlatformBrightnessChanged onPlatformBrightnessChanged) {
  kraken::registerOnPlatformBrightnessChanged(onPlatformBrightnessChanged);
}

Screen *createScreen(double width, double height) {
  screen.width = width;
  screen.height = height;
  return &screen;
}

void registerToBlob(ToBlob toBlob) {
  kraken::registerToBlob(toBlob);
}
