/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dart_callbacks.h"
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

} // namespace kraken
