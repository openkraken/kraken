/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DART_CALLBACKS_H_
#define KRAKEN_DART_CALLBACKS_H_

#include "thread_safe_map.h"
#include "kraken_bridge_export.h"
#include <memory>

namespace kraken {

struct DartFuncPointer {
  DartFuncPointer() = default;
  InvokeDartFromJS invokeDartFromJS{nullptr};
  ReloadApp reloadApp{nullptr};
  SetTimeout setTimeout{nullptr};
  SetInterval setInterval{nullptr};
  ClearTimeout clearTimeout{nullptr};
  RequestAnimationFrame requestAnimationFrame{nullptr};
  CancelAnimationFrame cancelAnimationFrame{nullptr};
  GetScreen getScreen{nullptr};
};

void registerInvokeDartFromJS(InvokeDartFromJS callback);
void registerReloadApp(ReloadApp callback);
void registerSetTimeout(SetTimeout callback);
void registerSetInterval(SetInterval callback);
void registerClearTimeout(ClearTimeout callback);
void registerRequestAnimationFrame(RequestAnimationFrame callback);
void registerCancelAnimationFrame(CancelAnimationFrame callback);
void registerGetScreen(GetScreen callback);

std::shared_ptr<DartFuncPointer> getDartFunc();

} // namespace kraken

#endif
