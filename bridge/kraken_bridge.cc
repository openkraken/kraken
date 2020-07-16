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
    kraken::getDartMethod()->onJsError(bridge.getContextIndex(), error.what());
  } else {
    KRAKEN_LOG(ERROR) << error.what() << std::endl;
  }
}

namespace {

void disposeAllBridge() {
  for (int i = 0; i <= poolIndex; i++) {
    disposeBridge(i);
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

void initJSBridgePool(int poolSize) {
  if (inited) disposeAllBridge();
  bridgePool = new kraken::JSBridge *[poolSize];
  for (int i = 1; i < poolSize; i++) {
    bridgePool[i] = nullptr;
  }

  bridgePool[0] = new kraken::JSBridge(0, printError);
  inited = true;
  maxPoolSize = poolSize;
}

void disposeBridge(int32_t bridgeIndex) {
  assert(bridgeIndex < maxPoolSize);
  assert(bridgePool[bridgeIndex] != nullptr);
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

void *getJSBridge(int32_t bridgeIndex) {
  assert(checkBridgeIndex(bridgeIndex) && "getJSBridge: bridgeIndex is not valid.");
  return bridgePool[bridgeIndex];
}

int32_t checkBridgeIndex(int32_t bridgeIndex) {
  return bridgeIndex < maxPoolSize && bridgePool[bridgeIndex] != nullptr;
}

void freezeBridge(int32_t bridgeIndex) {
  auto bridgePtr = getJSBridge(bridgeIndex);
  auto bridge = static_cast<kraken::JSBridge *>(bridgePtr);
  bridge->getContext()->freeze();
}

void unfreezeBridge(int32_t bridgeIndex) {
  auto bridgePtr = getJSBridge(bridgeIndex);
  auto bridge = static_cast<kraken::JSBridge *>(bridgePtr);
  bridge->getContext()->unfreeze();
}

bool isContextFreeze(int32_t bridgeIndex) {
  auto bridge = static_cast<kraken::JSBridge *>(getJSBridge(bridgeIndex));
  return bridge->getContext()->isFreeze();
}

void evaluateScripts(int32_t bridgeIndex, const char *code, const char *bundleFilename,
                     int startLine) {
  assert(checkBridgeIndex(bridgeIndex) && "evaluateScripts: bridgeIndex is not valid");
  auto bridge = static_cast<kraken::JSBridge *>(getJSBridge(bridgeIndex ));
  bridge->evaluateScript(std::string(code), std::string(bundleFilename), startLine);
}

void reloadJsContext(int32_t bridgeIndex) {
  assert(checkBridgeIndex(bridgeIndex) && "reloadJSContext: bridgeIndex is not valid");
  auto bridgePtr = getJSBridge(bridgeIndex);
  if (isContextFreeze(bridgeIndex)) return;
  auto bridge = static_cast<kraken::JSBridge *>(bridgePtr);
  delete bridge;
  bridge = new kraken::JSBridge(bridgeIndex, printError);
  bridgePool[bridgeIndex] = bridge;
}

void invokeEventListener(int32_t bridgeIndex, int32_t type, const char *data) {
  assert(checkBridgeIndex(bridgeIndex) && "invokeEventListener: bridgeIndex is not valid");
  if (isContextFreeze(bridgeIndex)) return;
  auto bridge = static_cast<kraken::JSBridge *>(getJSBridge(bridgeIndex));
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
