/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_EXPORT_H
#define KRAKEN_BRIDGE_EXPORT_H

#include <cstdint>
#include <thread>
#define KRAKEN_EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))

void *getJSContext(int32_t contextId);
std::__thread_id getUIThreadId();

struct NativeString {
  const uint16_t *string;
  int32_t length;
};

struct KrakenInfo;

using GetUserAgent = const char *(*)(KrakenInfo *);
struct KrakenInfo {
  const char *app_name{nullptr};
  const char *app_version{nullptr};
  const char *app_revision{nullptr};
  const char *system_name{nullptr};
  GetUserAgent getUserAgent;
};

struct NativeEventTarget;

using NativeEventTargetDispose = void(*)(int32_t contextId, NativeEventTarget *eventTarget);

struct NativeEventTarget {
  NativeEventTargetDispose dispose;
};

struct NativeNode : NativeEventTarget {};

struct NativeElement : NativeNode {
};

struct Screen {
  double width;
  double height;
};

using AsyncCallback = void (*)(void *callbackContext, int32_t contextId, const char *errmsg);
using AsyncRAFCallback = void (*)(void *callbackContext, int32_t contextId, double result, const char *errmsg);
using AsyncModuleCallback = void (*)(void *callbackContext, int32_t contextId, NativeString *json);
using AsyncBlobCallback = void (*)(void *callbackContext, int32_t contextId, const char *error, uint8_t *bytes,
                                   int32_t length);
typedef NativeString *(*InvokeUIManager)(int32_t contextId, NativeString *json);
typedef NativeString *(*InvokeModule)(void *callbackContext, int32_t contextId, NativeString *,
                                      AsyncModuleCallback callback);
typedef void (*RequestBatchUpdate)(void *callbackContext, int32_t contextId, AsyncCallback callback);
typedef void (*ReloadApp)(int32_t contextId);
typedef int32_t (*SetTimeout)(void *callbackContext, int32_t contextId, AsyncCallback callback, int32_t timeout);
typedef int32_t (*SetInterval)(void *callbackContext, int32_t contextId, AsyncCallback callback, int32_t timeout);
typedef int32_t (*RequestAnimationFrame)(void *callbackContext, int32_t contextId, AsyncRAFCallback callback);
typedef void (*ClearTimeout)(int32_t contextId, int32_t timerId);
typedef void (*CancelAnimationFrame)(int32_t contextId, int32_t id);
typedef Screen *(*GetScreen)(int32_t contextId);
typedef double (*DevicePixelRatio)(int32_t contextId);
typedef NativeString *(*PlatformBrightness)(int32_t contextId);
typedef void (*OnPlatformBrightnessChanged)(int32_t contextId);
typedef void (*ToBlob)(void *callbackContext, int32_t contextId, AsyncBlobCallback blobCallback, int32_t elementId,
                       double devicePixelRatio);
typedef void (*OnJSError)(int32_t contextId, const char *);
typedef void (*CreateElement)(int32_t contextId, NativeEventTarget* eventTarget, NativeString* tagName);
typedef NativeEventTarget* (*CreateEventTarget)(int32_t contextId);

KRAKEN_EXPORT
void initJSContextPool(int poolSize);
KRAKEN_EXPORT
void disposeContext(int32_t contextId);
KRAKEN_EXPORT
int32_t allocateNewContext();

KRAKEN_EXPORT
KrakenInfo *getKrakenInfo();

bool checkContext(int32_t contextId);
bool checkContext(int32_t contextId, void *context);
KRAKEN_EXPORT
void evaluateScripts(int32_t contextId, NativeString *code, const char *bundleFilename, int startLine);

KRAKEN_EXPORT
void uiFrameCallback();

KRAKEN_EXPORT
void reloadJsContext(int32_t contextId);
KRAKEN_EXPORT
void invokeEventListener(int32_t contextId, int32_t type, NativeString *code);
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
KRAKEN_EXPORT
void registerCreateElement(CreateElement createElement);
KRAKEN_EXPORT
void registerCreateEventTarget(CreateEventTarget createEventTarget);

#endif // KRAKEN_BRIDGE_EXPORT_H
