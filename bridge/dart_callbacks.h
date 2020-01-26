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
typedef int32_t(*SetTimeout)(int32_t, int32_t);

namespace kraken {

struct DartFuncPointer {
  DartFuncPointer() :
    invokeDartFromJS(nullptr),
    reloadApp(nullptr),
    setTimeout(nullptr){}
  InvokeDartFromJS invokeDartFromJS;
  ReloadApp reloadApp;
  SetTimeout setTimeout;
};

void registerInvokeDartFromJS(InvokeDartFromJS callback);
void registerReloadApp(ReloadApp callback);
void registerSetTimeout(SetTimeout callback);

DartFuncPointer* getDartFunc();

} // namespace kraken

#endif
