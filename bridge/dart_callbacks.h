/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DART_CALLBACKS_H_
#define KRAKEN_DART_CALLBACKS_H_

#include "thread_safe_map.h"
#include <memory>

typedef const char *(*InvokeDartFromJS)(const char *);
typedef void(*ReloadApp)();

namespace kraken {

struct DartFuncPointer {
  DartFuncPointer() :
    invokeDartFromJS(nullptr),
    reloadApp(nullptr){}
  InvokeDartFromJS invokeDartFromJS;
  ReloadApp reloadApp;
};

void registerInvokeDartFromJS(InvokeDartFromJS callback);
void registerReloadApp(ReloadApp callback);

DartFuncPointer* getDartFunc();

} // namespace kraken

#endif
