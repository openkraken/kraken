/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dart_callbacks.h"
#include "kraken_bridge_export.h"
#include <memory>

namespace kraken {

std::shared_ptr<DartFuncPointer> funcPointer =
    std::make_shared<DartFuncPointer>();

std::shared_ptr<DartFuncPointer> getDartFunc() {
  return funcPointer;
}

void registerInvokeDartFromJS(InvokeDartFromJS callback) {
  funcPointer->invokeDartFromJS = callback;
}

void registerReloadApp(ReloadApp callback) {
  funcPointer->reloadApp = callback;
}

void registerSetTimeout(SetTimeout callback) {
  funcPointer->setTimeout = callback;
}

void registerSetInterval(SetInterval callback) {
  funcPointer->setInterval = callback;
}

void registerClearTimeout(ClearTimeout callback) {
  funcPointer->clearTimeout = callback;
}

void registerRequestAnimationFrame(RequestAnimationFrame callback) {
  funcPointer->requestAnimationFrame = callback;
}

void registerCancelAnimationFrame(CancelAnimationFrame callback) {
  funcPointer->cancelAnimationFrame = callback;
}

void registerGetScreen(GetScreen callback) {
  funcPointer->getScreen = callback;
}

void registerInvokeFetch(InvokeFetch invokeFetch) {
  funcPointer->invokeFetch = invokeFetch;
}

void registerDevicePixelRatio(DevicePixelRatio devicePixelRatio) {
  funcPointer->devicePixelRatio = devicePixelRatio;
}

void registerPlatformBrightness(PlatformBrightness platformBrightness) {
  funcPointer->platformBrightness = platformBrightness;
}

void registerOnPlatformBrightnessChanged(OnPlatformBrightnessChanged onPlatformBrightnessChanged) {
  funcPointer->onPlatformBrightnessChanged = onPlatformBrightnessChanged;
}

} // namespace kraken
