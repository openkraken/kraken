/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DART_METHODS_H_
#define KRAKEN_DART_METHODS_H_

#include "kraken_bridge.h"
#include "kraken_bridge_test.h"
#include <thread>
#include <memory>

namespace kraken {

struct DartMethodPointer {
  DartMethodPointer() = default;
  InvokeModule invokeModule{nullptr};
  RequestBatchUpdate requestBatchUpdate{nullptr};
  ReloadApp reloadApp{nullptr};
  SetTimeout setTimeout{nullptr};
  SetInterval setInterval{nullptr};
  ClearTimeout clearTimeout{nullptr};
  RequestAnimationFrame requestAnimationFrame{nullptr};
  CancelAnimationFrame cancelAnimationFrame{nullptr};
  GetScreen getScreen{nullptr};
  DevicePixelRatio devicePixelRatio{nullptr};
  PlatformBrightness platformBrightness{nullptr};
  ToBlob toBlob{nullptr};
  OnJSError onJsError{nullptr};
  RefreshPaint refreshPaint{nullptr};
  MatchImageSnapshot matchImageSnapshot{nullptr};
  Environment environment{nullptr};
  SimulatePointer simulatePointer{nullptr};
  SimulateKeyPress simulateKeyPress{nullptr};
  FlushUICommand flushUICommand{nullptr};
  InitBody initBody{nullptr};
  InitWindow initWindow{nullptr};
};

void registerInvokeModule(InvokeModule callback);
void registerRequestBatchUpdate(RequestBatchUpdate callback);
void registerReloadApp(ReloadApp callback);
void registerSetTimeout(SetTimeout callback);
void registerSetInterval(SetInterval callback);
void registerClearTimeout(ClearTimeout callback);
void registerRequestAnimationFrame(RequestAnimationFrame callback);
void registerCancelAnimationFrame(CancelAnimationFrame callback);
void registerGetScreen(GetScreen callback);
void registerDevicePixelRatio(DevicePixelRatio devicePixelRatio);
void registerPlatformBrightness(PlatformBrightness platformBrightness);
void registerToBlob(ToBlob toBlob);
void registerJSError(OnJSError onJsError);
void registerFlushUICommand(FlushUICommand flushUiCommand);
void registerInitBody(InitBody initBody);
void registerInitWindow(InitWindow initWindow);

// test only methods
void registerRefreshPaint(RefreshPaint refreshPaint);
void registerMatchImageSnapshot(MatchImageSnapshot matchImageSnapshot);
void registerEnvironment(Environment environment);
void registerSimulatePointer(SimulatePointer simulatePointer);
void registerSimulateKeyPress(SimulateKeyPress simulateKeyPress);

std::shared_ptr<DartMethodPointer> getDartMethod();

} // namespace kraken

#endif
