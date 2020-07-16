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
kraken::JSBridge **bridgePool;
Screen screen;

void printError(alibaba::jsa::JSContext &bridge, const alibaba::jsa::JSError &error) {
  if (kraken::getDartMethod()->onJsError != nullptr) {
    kraken::getDartMethod()->onJsError(&bridge, bridge.getContextIndex(), error.what());
  } else {
    KRAKEN_LOG(ERROR) << error.what() << std::endl;
  }
}

namespace {

void disposeAllBridge() {
  for (int i = 0; i <= poolIndex; i++) {
    disposeBridge(bridgePool[i], i);
  }
  poolIndex = 0;
  inited = false;
}

int32_t searchForAvailableBridgeIndex() {
  for (int i = 0; i < maxPoolSize; i ++) {
    if (bridgePool[i] == nullptr) {
      return i;
    }
  }
  return -1;
}

} // namespace

void *initJSBridgePool(int poolSize) {
  if (inited) disposeAllBridge();
  bridgePool = new kraken::JSBridge *[poolSize];
  for (int i = 1; i < poolSize; i++) {
    bridgePool[i] = nullptr;
  }

  bridgePool[0] = new kraken::JSBridge(0, printError);
  inited = true;
  maxPoolSize = poolSize;
  return bridgePool[0];
}

void disposeBridge(void *bridgePtr, int32_t bridgeIndex) {
  assert(bridgeIndex < maxPoolSize);
  assert(bridgePool[bridgeIndex] != nullptr);
  assert(bridgePool[bridgeIndex] == bridgePtr);
  auto bridge = static_cast<kraken::JSBridge *>(bridgePool[bridgeIndex]);
  delete bridge;
  bridgePool[bridgeIndex] = nullptr;
}



int32_t allocateNewBridge() {
  poolIndex++;
  if (poolIndex >= maxPoolSize) {
    return searchForAvailableBridgeIndex();
  }

  assert(bridgePool[poolIndex] == nullptr && (std::string("can not allocate JSBridge at index") +
                                             std::to_string(poolIndex) + std::string(": bridge have already exist."))
                                              .c_str());

  auto bridge = new kraken::JSBridge(poolIndex, printError);
  bridgePool[poolIndex] = bridge;
  return poolIndex;
}

void *getJSBridge(int32_t contextIndex) {
  assert(checkBridgeIndex(contextIndex) && "getJSBridge: bridgeIndex is not valid.");
  return bridgePool[contextIndex];
}

int32_t checkBridgeIndex(int32_t bridgeIndex) {
  return bridgeIndex < maxPoolSize && bridgePool[bridgeIndex] != nullptr;
}

int32_t checkBridge(void *bridge, int32_t bridgeIndex) {
  return bridgePool[bridgeIndex] == bridge;
}

void freezeBridge(void *bridgePtr, int32_t bridgeIndex) {
  assert(checkBridge(bridgePtr, bridgeIndex) && "freeezeContext: bridge is not valid");
  auto bridge = static_cast<kraken::JSBridge *>(bridgePtr);
  bridge->getContext()->freeze();
}

void unfreezeBridge(void *bridgePtr, int32_t bridgeIndex) {
  assert(checkBridge(bridgePtr, bridgeIndex) && "unfreezeBridge: bridge is not valid");
  auto bridge = static_cast<kraken::JSBridge *>(bridgePtr);
  bridge->getContext()->unfreeze();
}

bool isContextFreeze(void *bridgePtr) {
  auto bridge = static_cast<kraken::JSBridge *>(bridgePtr);
  return bridge->getContext()->isFreeze();
}

void evaluateScripts(void *bridgePtr, int32_t bridgeIndex, const char *code, const char *bundleFilename,
                     int startLine) {
  assert(checkBridgeIndex(bridgeIndex) && "evaluateScripts: bridgeIndex is not valid");
  assert(checkBridge(bridgePtr, bridgeIndex) && "evaluateScripts: bridge is not valid");
  auto bridge = static_cast<kraken::JSBridge *>(bridgePtr);
  bridge->evaluateScript(std::string(code), std::string(bundleFilename), startLine);
}

void* reloadJsContext(void *bridgePtr, int32_t bridgeIndex) {
  assert(checkBridgeIndex(bridgeIndex) && "reloadJSContext: bridgeIndex is not valid");
  assert(checkBridge(bridgePtr, bridgeIndex) && "reloadJSContext: bridge is not valid");
  if (isContextFreeze(bridgePtr)) return nullptr;
  auto bridge = static_cast<kraken::JSBridge *>(bridgePtr);
  delete bridge;
  bridge = new kraken::JSBridge(bridgeIndex, printError);
  bridgePool[bridgeIndex] = bridge;
  return bridge;
}

void invokeEventListener(void *bridgePtr, int32_t bridgeIndex, int32_t type, const char *data) {
  assert(checkBridgeIndex(bridgeIndex) && "invokeEventListener: bridgeIndex is not valid");
  assert(checkBridge(bridgePtr, bridgeIndex) && "invokeEventListener: bridge is not valid");
  if (isContextFreeze(bridgePtr)) return;
  auto bridge = static_cast<kraken::JSBridge *>(bridgePtr);
  bridge->invokeEventListener(type, data);
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
