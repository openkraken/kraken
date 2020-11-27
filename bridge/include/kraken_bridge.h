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

  NativeString* clone() {
    NativeString *newNativeString = new NativeString();
    uint16_t *newString = new uint16_t[length];

    for (size_t i = 0; i < length; i ++) {
      newString[i] = string[i];
    }

    newNativeString->string = newString;
    newNativeString->length = length;
    return newNativeString;
  }

  void free() {
    delete[] string;
    delete this;
  }
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

struct Screen {
  double width;
  double height;
};

enum UICommand {
  createElement,
  createTextNode,
  createComment,
  disposeEventTarget,
  addEvent,
  removeNode,
  insertAdjacentNode,
  setStyle,
  setProperty,
  removeProperty
};

struct UICommandItem {
  UICommandItem(int64_t id, int32_t type, NativeString **args, size_t length, void* nativePtr)
    : type(type), args(args), id(id), length(length), nativePtr(nativePtr) {};
  int32_t type;
  NativeString **args;
  int64_t id;
  int32_t length;
  void* nativePtr;
};

using AsyncCallback = void (*)(void *callbackContext, int32_t contextId, const char *errmsg);
using AsyncRAFCallback = void (*)(void *callbackContext, int32_t contextId, double result, const char *errmsg);
using AsyncModuleCallback = void (*)(void *callbackContext, int32_t contextId, NativeString *json);
using AsyncBlobCallback = void (*)(void *callbackContext, int32_t contextId, const char *error, uint8_t *bytes,
                                   int32_t length);
typedef NativeString *(*InvokeModule)(void *callbackContext, int32_t contextId, NativeString *,
                                      AsyncModuleCallback callback);
typedef void (*RequestBatchUpdate)(int32_t contextId);
typedef void (*ReloadApp)(int32_t contextId);
typedef int32_t (*SetTimeout)(void *callbackContext, int32_t contextId, AsyncCallback callback, int32_t timeout);
typedef int32_t (*SetInterval)(void *callbackContext, int32_t contextId, AsyncCallback callback, int32_t timeout);
typedef int32_t (*RequestAnimationFrame)(void *callbackContext, int32_t contextId, AsyncRAFCallback callback);
typedef void (*ClearTimeout)(int32_t contextId, int32_t timerId);
typedef void (*CancelAnimationFrame)(int32_t contextId, int32_t id);
typedef Screen *(*GetScreen)(int32_t contextId);
typedef double (*DevicePixelRatio)(int32_t contextId);
typedef NativeString *(*PlatformBrightness)(int32_t contextId);
typedef void (*ToBlob)(void *callbackContext, int32_t contextId, AsyncBlobCallback blobCallback, int32_t elementId,
                       double devicePixelRatio);
typedef void (*OnJSError)(int32_t contextId, const char *);
typedef void (*FlushUICommand)();
typedef void (*InitBody)(int32_t contextId, void *nativePtr);
typedef void (*InitWindow)(int32_t contextId, void *nativePtr);

KRAKEN_EXPORT
void initJSContextPool(int poolSize);
KRAKEN_EXPORT
void disposeContext(int32_t contextId);
KRAKEN_EXPORT
int32_t allocateNewContext();

KRAKEN_EXPORT
KrakenInfo *getKrakenInfo();

KRAKEN_EXPORT
UICommandItem **getUICommandItems(int32_t contextId);
KRAKEN_EXPORT
int64_t getUICommandItemSize(int32_t contextId);
KRAKEN_EXPORT
void clearUICommandItems(int32_t contextId);

bool checkContext(int32_t contextId);
bool checkContext(int32_t contextId, void *context);
KRAKEN_EXPORT
void evaluateScripts(int32_t contextId, NativeString *code, const char *bundleFilename, int startLine);

KRAKEN_EXPORT
void flushBridgeTask();

KRAKEN_EXPORT
void reloadJsContext(int32_t contextId);
KRAKEN_EXPORT
void invokeEventListener(int32_t contextId, int32_t type, NativeString *code);
KRAKEN_EXPORT
Screen *createScreen(double width, double height);

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
void registerToBlob(ToBlob toBlob);
KRAKEN_EXPORT
void registerFlushUICommand(FlushUICommand flushUICommand);
KRAKEN_EXPORT
void registerInitBody(InitBody initBody);
KRAKEN_EXPORT
void registerInitWindow(InitWindow initWindow);

#endif // KRAKEN_BRIDGE_EXPORT_H
