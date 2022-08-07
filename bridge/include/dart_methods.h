/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

#ifndef WEBF_DART_METHODS_H_
#define WEBF_DART_METHODS_H_

#include "webf_bridge.h"

#include <memory>
#include <thread>

#define WEBF_EXPORT __attribute__((__visibility__("default")))

struct NativeString;
struct NativeScreen;

using AsyncCallback = void (*)(void* callbackContext, int32_t contextId, const char* errmsg);
using AsyncRAFCallback = void (*)(void* callbackContext, int32_t contextId, double result, const char* errmsg);
using AsyncModuleCallback = void (*)(void* callbackContext, int32_t contextId, const char* errmsg, NativeString* json);
using AsyncBlobCallback = void (*)(void* callbackContext, int32_t contextId, const char* error, uint8_t* bytes, int32_t length);
typedef NativeString* (*InvokeModule)(void* callbackContext, int32_t contextId, NativeString* moduleName, NativeString* method, NativeString* params, AsyncModuleCallback callback);
typedef void (*RequestBatchUpdate)(int32_t contextId);
typedef void (*ReloadApp)(int32_t contextId);
typedef int32_t (*SetTimeout)(void* callbackContext, int32_t contextId, AsyncCallback callback, int32_t timeout);
typedef int32_t (*SetInterval)(void* callbackContext, int32_t contextId, AsyncCallback callback, int32_t timeout);
typedef int32_t (*RequestAnimationFrame)(void* callbackContext, int32_t contextId, AsyncRAFCallback callback);
typedef void (*ClearTimeout)(int32_t contextId, int32_t timerId);
typedef void (*CancelAnimationFrame)(int32_t contextId, int32_t id);
typedef NativeScreen* (*GetScreen)(int32_t contextId);
typedef void (*ToBlob)(void* callbackContext, int32_t contextId, AsyncBlobCallback blobCallback, int32_t elementId, double devicePixelRatio);
typedef void (*OnJSError)(int32_t contextId, const char*);
typedef void (*OnJSLog)(int32_t contextId, int32_t level, const char*);
typedef void (*FlushUICommand)();
typedef void (*InitWindow)(int32_t contextId, void* nativePtr);
typedef void (*InitDocument)(int32_t contextId, void* nativePtr);

using MatchImageSnapshotCallback = void (*)(void* callbackContext, int32_t contextId, int8_t, const char* errmsg);
using MatchImageSnapshot = void (*)(void* callbackContext, int32_t contextId, uint8_t* bytes, int32_t length, NativeString* name, MatchImageSnapshotCallback callback);
using Environment = const char* (*)();

#if ENABLE_PROFILE
struct NativePerformanceEntryList {
  uint64_t* entries;
  int32_t length;
};
typedef NativePerformanceEntryList* (*GetPerformanceEntries)(int32_t);
#endif

struct MousePointer {
  int32_t contextId;
  double x;
  double y;
  double change;
};
using SimulatePointer = void (*)(MousePointer**, int32_t length, int32_t pointer);
using SimulateInputText = void (*)(NativeString* nativeString);

namespace webf {
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
  ToBlob toBlob{nullptr};
  OnJSError onJsError{nullptr};
  OnJSLog onJsLog{nullptr};
  MatchImageSnapshot matchImageSnapshot{nullptr};
  Environment environment{nullptr};
  SimulatePointer simulatePointer{nullptr};
  SimulateInputText simulateInputText{nullptr};
  FlushUICommand flushUICommand{nullptr};
#if ENABLE_PROFILE
  GetPerformanceEntries getPerformanceEntries{nullptr};
#endif
  InitWindow initWindow{nullptr};
  InitDocument initDocument{nullptr};
};

void registerDartMethods(uint64_t* methodBytes, int32_t length);

#ifdef IS_TEST
WEBF_EXPORT
void registerTestEnvDartMethods(uint64_t* methodBytes, int32_t length);
#endif

WEBF_EXPORT
std::shared_ptr<DartMethodPointer> getDartMethod();

}  // namespace webf

#endif
