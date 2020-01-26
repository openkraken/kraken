/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dart_callbacks.h"

namespace kraken {

DartFuncPointer funcPointer;

DartFuncPointer* getDartFunc() { return &funcPointer; }

void registerInvokeDartFromJS(InvokeDartFromJS callback) {
  funcPointer.invokeDartFromJS = callback;
}

void registerReloadApp(ReloadApp callback) {
  funcPointer.reloadApp = callback;
}

}
