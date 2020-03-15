/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DART_METHODS_H_
#define KRAKEN_DART_METHODS_H_

#include "bridge_export.h"
#include "bridge_test_export.h"
#include "thread_safe_map.h"
#include <memory>

namespace kraken {

struct DartMethodPointer {
  DartMethodPointer() = default;
  InvokeUIManager invokeUIManager{nullptr};
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
  OnPlatformBrightnessChanged onPlatformBrightnessChanged{nullptr};
  StartFlushCallbacksInUIThread startFlushCallbacksInUIThread{nullptr};
  StopFlushCallbacksInUIThread stopFlushCallbacksInUIThread{nullptr};
  ToBlob toBlob{nullptr};
  OnJSError onJsError{nullptr};
  RefreshPaint refreshPaint{nullptr};
  MatchScreenShot matchScreenShot{nullptr};
};

void registerInvokeUIManager(InvokeUIManager callback);
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
void registerOnPlatformBrightnessChanged(OnPlatformBrightnessChanged onPlatformBrightnessChanged);
void registerStartFlushUILoop(StartFlushCallbacksInUIThread startFlushUiLoop);
void registerStopFlushCallbacksInUIThread(StopFlushCallbacksInUIThread stopFlushUiLoop);
void registerToBlob(ToBlob toBlob);
void registerJSError(OnJSError onJsError);

// test only methods
void registerRefreshPaint(RefreshPaint refreshPaint);
void registerMatchScreenShot(MatchScreenShot matchScreenShot);

std::shared_ptr<DartMethodPointer> getDartMethod();

} // namespace kraken

#endif
