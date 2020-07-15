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

void printError(alibaba::jsa::JSContext &context, const alibaba::jsa::JSError &error) {
  if (kraken::getDartMethod()->onJsError != nullptr) {
    kraken::getDartMethod()->onJsError(&context, context.getContextIndex(), error.what());
  } else {
    KRAKEN_LOG(ERROR) << error.what() << std::endl;
  }
}

void *initJSContextPool(int poolSize) {
  if (inited) {
    for (int i = 0; i < poolIndex; i ++) {
      disposeContext(bridgePool[i], i);
    }
    inited = false;
  };
  bridgePool = new void *[poolSize];
  for (int i = 1; i < poolSize; i++) {
    bridgePool[i] = nullptr;
  }

  bridgePool[0] = new kraken::JSBridge(0, printError);
  inited = true;
  maxPoolSize = poolSize;
  return bridgePool[0];
}

void disposeContext(void *context, int32_t contextIndex) {
  assert(contextIndex < maxPoolSize);
  assert(bridgePool[contextIndex] != nullptr);
  assert(bridgePool[contextIndex] == context);
  auto bridge = static_cast<kraken::JSBridge *>(bridgePool[contextIndex]);
  delete bridge;
}

int32_t allocateNewContext() {
  int newIndex = poolIndex.fetch_add(std::memory_order::memory_order_acquire);
  assert(newIndex < maxPoolSize);
  auto bridge = new kraken::JSBridge(newIndex, printError);
  bridgePool[newIndex] = bridge;
  return newIndex;
}

void *getJSContext(int32_t contextIndex) {
  assert(checkContextIndex(contextIndex) && "getJSContext: contextIndex is not valid.");
  return bridgePool[contextIndex];
}

int32_t checkContextIndex(int32_t contextIndex) {
  return contextIndex < maxPoolSize && bridgePool[contextIndex] != nullptr;
}

int32_t checkContext(void *context, int32_t contextIndex) {
  return bridgePool[contextIndex] == context;
}

void freezeContext(void *context, int32_t contextIndex) {
  checkContext(context, contextIndex);
}

void unfreezeContext(void *context, int32_t contextIndex) {

}

bool isContextFreeze(void *context) {
  auto bridge = static_cast<kraken::JSBridge *>(context);
  return bridge->getContext()->isFreeze();
}


void evaluateScripts(void *context, int32_t contextIndex, const char *code, const char *bundleFilename, int startLine) {
  assert(checkContextIndex(contextIndex) && "evaluateScripts: contextIndex is not valid");
  assert(checkContext(context, contextIndex) && "evaluateScripts: context is not valid");
  auto bridge = static_cast<kraken::JSBridge *>(context);
  bridge->evaluateScript(std::string(code), std::string(bundleFilename), startLine);
}

void reloadJsContext(void *context, int32_t contextIndex) {
  assert(checkContextIndex(contextIndex) && "reloadJSContext: contextIndex is not valid");
  assert(checkContext(context, contextIndex) && "reloadJSContext: context is not valid");
  if (isContextFreeze(context)) return;
  auto bridge = static_cast<kraken::JSBridge *>(context);
  delete bridge;
  bridge = new kraken::JSBridge(contextIndex, printError);
  bridgePool[contextIndex] = bridge;
}

void invokeEventListener(void *context, int32_t contextIndex, int32_t type, const char *data) {
  assert(checkContextIndex(contextIndex) && "invokeEventListener: contextIndex is not valid");
  assert(checkContext(context, contextIndex) && "invokeEventListener: context is not valid");
  if (isContextFreeze(context)) return;
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
