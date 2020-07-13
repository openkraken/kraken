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
using AsyncCallback = void (*)(void *context, int32_t contextIndex, const char* errmsg);
using AsyncRAFCallback = void (*)(void *context, int32_t contextIndex, double result, const char* errmsg);
using AsyncModuleCallback = void (*)(void *context, int32_t contextIndex, char *json, void *data);
using AsyncBlobCallback = void (*)(void *context, int32_t contextIndex, const char *error, uint8_t *bytes, int32_t length);
typedef const char *(*InvokeUIManager)(const char *);
typedef const char *(*InvokeModule)(const char *, AsyncModuleCallback callback, void *context, int32_t contextIndex);
typedef void (*RequestBatchUpdate)(AsyncCallback callback, void *context, int32_t contextIndex);
typedef void (*ReloadApp)();
typedef int32_t (*SetTimeout)(AsyncCallback callback, void *context, int32_t contextIndex, int32_t timeout);
typedef int32_t (*SetInterval)(AsyncCallback callback, void *context, int32_t contextIndex, int32_t timeout);
typedef int32_t (*RequestAnimationFrame)(AsyncRAFCallback callback, void *context, int32_t contextIndex);
typedef void (*ClearTimeout)(int32_t);
typedef void (*CancelAnimationFrame)(int32_t);
typedef Screen *(*GetScreen)();
typedef void (*InvokeFetch)(int32_t, const char *, const char *);
typedef double (*DevicePixelRatio)();
typedef const char *(*PlatformBrightness)();
typedef void (*OnPlatformBrightnessChanged)();
typedef void (*ToBlob)(AsyncBlobCallback blobCallback, void *context, int32_t contextIndex, double);
typedef void (*OnJSError)(const char *);

KRAKEN_EXPORT
void* initJSEnginePool(int poolSize);
KRAKEN_EXPORT
void disposeEngine(void *context, int32_t contextIndex);
KRAKEN_EXPORT
int32_t allocateNewJSEngine();
KRAKEN_EXPORT
void *getJSEngine(int32_t);
KRAKEN_EXPORT
int32_t checkEngineIndex(int32_t contextIndex);
KRAKEN_EXPORT
int32_t checkEngine(void *context, int32_t contextIndex);
KRAKEN_EXPORT
void evaluateScripts(void* context, int32_t contextIndex, const char *code, const char *bundleFilename, int startLine);

KRAKEN_EXPORT
void reloadJsContext(void *context, int32_t contextIndex);
KRAKEN_EXPORT
void invokeEventListener(void *context, int32_t contextIndex, int32_t type, const char *json);
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
