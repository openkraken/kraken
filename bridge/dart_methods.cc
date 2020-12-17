/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dart_methods.h"
#include "kraken_bridge.h"
#include <memory>

namespace kraken {

std::shared_ptr<DartMethodPointer> methodPointer = std::make_shared<DartMethodPointer>();

std::shared_ptr<DartMethodPointer> getDartMethod() {
  std::__thread_id currentThread = std::this_thread::get_id();

#ifndef NDEBUG
  // Dart methods can only invoked from Flutter UI threads. Javascript Debugger like Safari Debugger can invoke
  // Javascript methods from debugger thread and will crash the app.
  // @TODO: implement task loops for async method call.
  if (currentThread != getUIThreadId()) {
    // return empty struct to stop further behavior.
    return std::make_shared<DartMethodPointer>();
  }
#endif

  return methodPointer;
}

void registerInvokeModule(InvokeModule callback) {
  methodPointer->invokeModule = callback;
}

void registerReloadApp(ReloadApp callback) {
  methodPointer->reloadApp = callback;
}

void registerSetTimeout(SetTimeout callback) {
  methodPointer->setTimeout = callback;
}

void registerSetInterval(SetInterval callback) {
  methodPointer->setInterval = callback;
}

void registerClearTimeout(ClearTimeout callback) {
  methodPointer->clearTimeout = callback;
}

void registerRequestAnimationFrame(RequestAnimationFrame callback) {
  methodPointer->requestAnimationFrame = callback;
}

void registerRequestBatchUpdate(RequestBatchUpdate callback) {
  methodPointer->requestBatchUpdate = callback;
}

void registerCancelAnimationFrame(CancelAnimationFrame callback) {
  methodPointer->cancelAnimationFrame = callback;
}

void registerGetScreen(GetScreen callback) {
  methodPointer->getScreen = callback;
}

void registerDevicePixelRatio(DevicePixelRatio devicePixelRatio) {
  methodPointer->devicePixelRatio = devicePixelRatio;
}

void registerPlatformBrightness(PlatformBrightness platformBrightness) {
  methodPointer->platformBrightness = platformBrightness;
}

void registerToBlob(ToBlob toBlob) {
  methodPointer->toBlob = toBlob;
}

void registerJSError(OnJSError onJsError) {
  methodPointer->onJsError = onJsError;
}

void registerRefreshPaint(RefreshPaint refreshPaint) {
  methodPointer->refreshPaint = refreshPaint;
}

void registerMatchImageSnapshot(MatchImageSnapshot matchImageSnapshot) {
  methodPointer->matchImageSnapshot = matchImageSnapshot;
}

void registerEnvironment(Environment environment) {
  methodPointer->environment = environment;
}

void registerSimulatePointer(SimulatePointer simulatePointer) {
  methodPointer->simulatePointer = simulatePointer;
}

void registerSimulateKeyPress(SimulateKeyPress simulateKeyPress) {
  methodPointer->simulateKeyPress = simulateKeyPress;
}

void registerFlushUICommand(FlushUICommand flushUiCommand){
  methodPointer->flushUICommand = flushUiCommand;
};

void registerInitBody(InitBody initBody) {
  methodPointer->initBody = initBody;
}

void registerInitWindow(InitWindow initWindow) {
  methodPointer->initWindow = initWindow;
}

void registerGetPerformanceEntries(GetPerformanceEntries getPerformanceEntries) {
  methodPointer->getPerformanceEntries = getPerformanceEntries;
}

} // namespace kraken
