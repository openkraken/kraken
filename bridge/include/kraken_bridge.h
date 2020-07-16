/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_EXPORT_H
#define KRAKEN_BRIDGE_EXPORT_H

#include <cstdint>
#define KRAKEN_EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))

struct Screen {
  double width;
  double height;
};
using AsyncCallback = void (*)(void *callbackContext, void *bridge, int32_t contextIndex, const char *errmsg);
using AsyncRAFCallback = void (*)(void *callbackContext, void *bridge, int32_t contextIndex, double result, const char *errmsg);
using AsyncModuleCallback = void (*)(void *callbackContext, void *bridge, int32_t contextIndex, char *json);
using AsyncBlobCallback = void (*)(void *callbackContext, void *bridge, int32_t contextIndex, const char *error, uint8_t *bytes,
                                   int32_t length);
typedef const char *(*InvokeUIManager)(void *bridge, int32_t contextIndex, const char *json);
typedef const char *(*InvokeModule)(void *callbackContext, void *bridge, int32_t contextIndex, const char *, AsyncModuleCallback callback);
typedef void (*RequestBatchUpdate)(void *callbackContext, void *bridge, int32_t contextIndex, AsyncCallback callback);
typedef void (*ReloadApp)(void *bridge, int32_t contextIndex);
typedef int32_t (*SetTimeout)(void *callbackContext, void *bridge, int32_t contextIndex, AsyncCallback callback, int32_t timeout);
typedef int32_t (*SetInterval)(void *callbackContext, void *bridge, int32_t contextIndex, AsyncCallback callback, int32_t timeout);
typedef int32_t (*RequestAnimationFrame)(void *callbackContext, void *bridge, int32_t contextIndex, AsyncRAFCallback callback);
typedef void (*ClearTimeout)(void *bridge, int32_t contextIndex, int32_t timerId);
typedef void (*CancelAnimationFrame)(void *bridge, int32_t contextIndex, int32_t id);
typedef Screen *(*GetScreen)(void *bridge, int32_t contextIndex);
typedef double (*DevicePixelRatio)(void *bridge, int32_t contextIndex);
typedef const char *(*PlatformBrightness)(void *bridge, int32_t contextIndex);
typedef void (*OnPlatformBrightnessChanged)(void *bridge, int32_t contextIndex);
typedef void (*ToBlob)(void *callbackContext, void *bridge, int32_t contextIndex, AsyncBlobCallback blobCallback, int32_t elementId,
                       double devicePixelRatio);
typedef void (*OnJSError)(void *bridge, int32_t contextIndex, const char *);

KRAKEN_EXPORT
void *initJSBridgePool(int poolSize);
KRAKEN_EXPORT
void disposeBridge(void *bridgePtr, int32_t contextIndex);
KRAKEN_EXPORT
int32_t allocateNewBridge();
KRAKEN_EXPORT
void *getJSBridge(int32_t contextIndex);
KRAKEN_EXPORT
int32_t checkBridgeIndex(int32_t contextIndex);
KRAKEN_EXPORT
int32_t checkBridge(void *bridge, int32_t bridgeIndex);
KRAKEN_EXPORT
void freezeBridge(void *bridge, int32_t bridgeIndex);
KRAKEN_EXPORT
void unfreezeBridge(void *bridge, int32_t bridgeIndex);
KRAKEN_EXPORT
void evaluateScripts(void *bridge, int32_t contextIndex, const char *code, const char *bundleFilename, int startLine);

KRAKEN_EXPORT
void* reloadJsContext(void *bridge, int32_t contextIndex);
KRAKEN_EXPORT
void invokeEventListener(void *bridge, int32_t contextIndex, int32_t type, const char *json);
KRAKEN_EXPORT
Screen *createScreen(double width, double height);

KRAKEN_EXPORT
void registerInvokeUIManager(InvokeUIManager invokeUIManager);
KRAKEN_EXPORT
void registerInvokeModule(InvokeModule invokeUIManager);
KRAKEN_EXPORT
void registerRequestBatchUpdate(RequestBatchUpdate requestBatchUpdate);
KRAKEN_EXPORT
void registerReloadApp(ReloadApp reloadApp);
KRAKEN_EXPORT
void registerSetTimeout(SetTimeout setTimeout);
KRAKEN_EXPORT
void registerSetInterval(SetInterval setInterval);
KRAKEN_EXPORT
void registerClearTimeout(ClearTimeout clearTimeout);
KRAKEN_EXPORT
void registerRequestAnimationFrame(RequestAnimationFrame requestAnimationFrame);
KRAKEN_EXPORT
void registerCancelAnimationFrame(CancelAnimationFrame cancelAnimationFrame);
KRAKEN_EXPORT
void registerGetScreen(GetScreen getScreen);
KRAKEN_EXPORT
void registerDevicePixelRatio(DevicePixelRatio devicePixelRatio);
KRAKEN_EXPORT
void registerPlatformBrightness(PlatformBrightness platformBrightness);
KRAKEN_EXPORT
void registerOnPlatformBrightnessChanged(OnPlatformBrightnessChanged onPlatformBrightnessChanged);
KRAKEN_EXPORT
void registerToBlob(ToBlob toBlob);

#endif // KRAKEN_BRIDGE_EXPORT_H
