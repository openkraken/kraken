/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_EXPORT_H
#define KRAKEN_BRIDGE_EXPORT_H

#include <cstdint>
#define KRAKEN_EXPORT                                                          \
  extern "C" __attribute__((visibility("default"))) __attribute__((used))

struct Screen {
  double width;
  double height;
};

typedef const char *(*InvokeDartFromJS)(const char *);
typedef void (*ReloadApp)();
typedef int32_t (*SetTimeout)(int32_t, int32_t);
typedef int32_t (*SetInterval)(int32_t, int32_t);
typedef void (*ClearTimeout)(int32_t);
typedef int32_t (*RequestAnimationFrame)(int32_t);
typedef void (*CancelAnimationFrame)(int32_t);
typedef Screen *(*GetScreen)();
typedef double (*DevicePixelRatio)();
typedef void (*InvokeFetch)(int32_t, const char*, const char*);

KRAKEN_EXPORT
void initJsEngine();
KRAKEN_EXPORT
void evaluateScripts(const char *code, const char *bundleFilename,
                     int startLine);
KRAKEN_EXPORT
void reloadJsContext();
KRAKEN_EXPORT
void invokeKrakenCallback(const char *data);
KRAKEN_EXPORT
Screen *createScreen(double width, double height);
KRAKEN_EXPORT
void invokeSetTimeoutCallback(int32_t callbackId);
KRAKEN_EXPORT
void invokeSetIntervalCallback(int32_t callbackId);
KRAKEN_EXPORT
void invokeRequestAnimationFrameCallback(int32_t callbackId);
KRAKEN_EXPORT
void invokeOnloadCallback();
KRAKEN_EXPORT
void invokeFetchCallback(int32_t callbackId, const char* error, int32_t statusCode,
                         const char* body);

KRAKEN_EXPORT
void registerInvokeDartFromJS(InvokeDartFromJS invokeDartFromJs);
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
void registerInvokeFetch(InvokeFetch invokeFetch);
KRAKEN_EXPORT
void registerDevicePixelRatio(DevicePixelRatio devicePixelRatio);

#endif // KRAKEN_BRIDGE_EXPORT_H
