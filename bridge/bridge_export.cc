/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_export.h"
#include "dart_methods.h"
#include "bridge.h"
#include <atomic>
#include <string>
#include <iostream>

kraken::DartMethodPointer funcPointer;
// this is not thread safe
std::atomic<bool> inited{false};
std::unique_ptr<kraken::JSBridge> bridge;

void printError(const alibaba::jsa::JSError &error) {
  if (kraken::getDartMethod()->onJsError != nullptr) {
    kraken::getDartMethod()->onJsError(error.what());
  }
  std::cerr << error.what() << std::endl;
}

Screen screen;

void reloadJsContext() {
  inited = false;
  bridge = std::make_unique<kraken::JSBridge>(printError);
  inited = true;
}

void initJsEngine() {
  bridge = std::make_unique<kraken::JSBridge>(printError);
  inited = true;
}

void evaluateScripts(const char *code, const char *bundleFilename,
                      int startLine) {
  if (!inited) return;
  bridge->evaluateScript(std::string(code), std::string(bundleFilename),
                         startLine);
}

void invokeEventListener(int32_t type,const char *data) {
  if (!inited) return;
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

void invokeOnloadCallback() {
  bridge->invokeOnloadCallback();
}

void invokeOnPlatformBrightnessChangedCallback() {
  bridge->invokeOnPlatformBrightnessChangedCallback();
}

void flushUITask() {
  bridge->flushUITask();
}

void registerStartFlushCallbacksInUIThread(
    StartFlushCallbacksInUIThread startFlushCallbacksInUIThread) {
  kraken::registerStartFlushUILoop(startFlushCallbacksInUIThread);
}

void registerStopFlushCallbacksInUIThread(
    StopFlushCallbacksInUIThread stopFlushCallbacksInUiThread) {
  kraken::registerStopFlushCallbacksInUIThread(stopFlushCallbacksInUiThread);
}

void registerToBlob(ToBlob toBlob) {
  kraken::registerToBlob(toBlob);
}

void registerOnJSError(OnJSError jsError) {
  kraken::registerOnJSError(jsError);
}
