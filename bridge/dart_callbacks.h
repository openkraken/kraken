/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DART_CALLBACKS_H_
#define KRAKEN_DART_CALLBACKS_H_

#include "thread_safe_map.h"
#include <memory>

typedef const char *(*InvokeDartFromJS)(const char *);
typedef void (*ReloadApp)();
typedef int32_t (*SetTimeout)(int32_t, int32_t);
typedef int32_t (*SetInterval)(int32_t, int32_t);
typedef void (*ClearTimeout)(int32_t);
typedef int32_t (*RequestAnimationFrame)(int32_t);

namespace kraken {

struct DartFuncPointer {
  DartFuncPointer() = default;
  InvokeDartFromJS invokeDartFromJS{nullptr};
  ReloadApp reloadApp{nullptr};
  SetTimeout setTimeout{nullptr};
  SetInterval setInterval{nullptr};
  ClearTimeout clearTimeout{nullptr};
  RequestAnimationFrame requestAnimationFrame{nullptr};
};

void registerInvokeDartFromJS(InvokeDartFromJS callback);
void registerReloadApp(ReloadApp callback);
void registerSetTimeout(SetTimeout callback);
void registerSetInterval(SetInterval callback);
void registerClearTimeout(ClearTimeout callback);
void registerRequestAnimationFrame(RequestAnimationFrame callback);

std::shared_ptr<DartFuncPointer> getDartFunc();

} // namespace kraken

#endif
