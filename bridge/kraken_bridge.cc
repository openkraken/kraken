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
void **bridgePool;
Screen screen;

void printError(const alibaba::jsa::JSError &error) {
  if (kraken::getDartMethod()->onJsError != nullptr) {
    kraken::getDartMethod()->onJsError(error.what());
  } else {
    KRAKEN_LOG(ERROR) << error.what() << std::endl;
  }
}

void *initJSEnginePool(int poolSize) {
  assert(inited && "JS context Pool has already inited");
  bridgePool = new void *[poolSize];
  for (int i = 1; i < poolSize; i++) {
    bridgePool[i] = nullptr;
  }

  bridgePool[0] = new kraken::JSBridge(0, printError);
  inited = true;
  maxPoolSize = poolSize;
  return bridgePool[0];
}

void disposeEngine(void *context, int32_t contextIndex) {
  assert(contextIndex < maxPoolSize);
  assert(bridgePool[contextIndex] != nullptr);
  assert(bridgePool[contextIndex] == context);
  auto bridge = static_cast<kraken::JSBridge *>(bridgePool[contextIndex]);
  delete bridge;
}

int32_t allocateNewJSEngine() {
  int newIndex = poolIndex.fetch_add(std::memory_order::memory_order_acquire);
  assert(newIndex < maxPoolSize);
  auto bridge = new kraken::JSBridge(newIndex, printError);
  bridgePool[newIndex] = bridge;
  return newIndex;
}

void *getJSEngine(int32_t contextIndex) {
  assert(checkEngineIndex(contextIndex) && "getJSEngine: contextIndex is not valid.");
  return bridgePool[contextIndex];
}

int32_t checkEngineIndex(int32_t contextIndex) {
  return contextIndex < maxPoolSize && bridgePool[contextIndex] != nullptr;
}

int32_t checkEngine(void *context, int32_t contextIndex) {
  assert(checkEngineIndex(contextIndex) && "checkEngine: contextIndex is not valid.");
  return bridgePool[contextIndex] == context;
}

void evaluateScripts(void *context, int32_t contextIndex, const char *code, const char *bundleFilename, int startLine) {
  assert(checkEngineIndex(contextIndex) && "evaluateScripts: contextIndex is not valid");
  assert(checkEngine(context, contextIndex) && "evaluateScripts: context is not valid");
  auto bridge = static_cast<kraken::JSBridge *>(context);
  bridge->evaluateScript(std::string(code), std::string(bundleFilename), startLine);
}

void reloadJsContext(void *context, int32_t contextIndex) {
  assert(checkEngineIndex(contextIndex) && "reloadJSContext: contextIndex is not valid");
  assert(checkEngine(context, contextIndex) && "reloadJSContext: context is not valid");
  auto bridge = static_cast<kraken::JSBridge *>(context);
  delete bridge;
  bridge = new kraken::JSBridge(contextIndex, printError);
  bridgePool[contextIndex] = bridge;
}

void invokeEventListener(void *context, int32_t contextIndex, int32_t type, const char *data) {
  assert(checkEngineIndex(contextIndex) && "invokeEventListener: contextIndex is not valid");
  assert(checkEngine(context, contextIndex) && "invokeEventListener: context is not valid");
  auto bridge = static_cast<kraken::JSBridge *>(context);
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
