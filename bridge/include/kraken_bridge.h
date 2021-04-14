/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_EXPORT_H
#define KRAKEN_BRIDGE_EXPORT_H

#include <cstdint>
#include <thread>

#include "kraken_foundation.h"
#include "dart_methods.h"

#if KRAKEN_JSC_ENGINE
#include "kraken_bridge_jsc.h"
#endif

#define KRAKEN_EXPORT_C extern "C" __attribute__((visibility("default"))) __attribute__((used))
#define KRAKEN_EXPORT __attribute__((__visibility__("default")))

KRAKEN_EXPORT_C
void *getJSContext(int32_t contextId);
std::__thread_id getUIThreadId();

struct KRAKEN_EXPORT NativeString {
  const uint16_t *string;
  int32_t length;

  NativeString *clone();
  void free();
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
  removeProperty,
  cloneNode
};

struct KRAKEN_EXPORT UICommandItem {
  UICommandItem(int32_t id, int32_t type, NativeString args_01, NativeString args_02, void *nativePtr)
    : type(type), string_01(reinterpret_cast<int64_t>(args_01.string)), args_01_length(args_01.length),
      string_02(reinterpret_cast<int64_t>(args_02.string)), args_02_length(args_02.length), id(id),
      nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  UICommandItem(int32_t id, int32_t type, NativeString args_01, void *nativePtr)
    : type(type), string_01(reinterpret_cast<int64_t>(args_01.string)), args_01_length(args_01.length), id(id),
      nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  UICommandItem(int32_t id, int32_t type, void *nativePtr)
    : type(type), id(id), nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  int32_t type;
  int32_t id;
  int32_t args_01_length{0};
  int32_t args_02_length{0};
  int64_t string_01{0};
  int64_t string_02{0};
  int64_t nativePtr{0};
};

KRAKEN_EXPORT_C
void initJSContextPool(int poolSize);
KRAKEN_EXPORT_C
void disposeContext(int32_t contextId);
KRAKEN_EXPORT_C
int32_t allocateNewContext();

KRAKEN_EXPORT_C
KrakenInfo *getKrakenInfo();

KRAKEN_EXPORT_C
UICommandItem *getUICommandItems(int32_t contextId);
KRAKEN_EXPORT_C
int64_t getUICommandItemSize(int32_t contextId);
KRAKEN_EXPORT_C
void clearUICommandItems(int32_t contextId);

bool checkContext(int32_t contextId);
bool checkContext(int32_t contextId, void *context);
KRAKEN_EXPORT_C
void evaluateScripts(int32_t contextId, NativeString *code, const char *bundleFilename, int startLine);

KRAKEN_EXPORT_C
void dispatchUITask(int32_t contextId, int32_t taskId);
KRAKEN_EXPORT_C
void flushUICommandCallback();

KRAKEN_EXPORT_C
void reloadJsContext(int32_t contextId);
KRAKEN_EXPORT_C
void invokeModuleEvent(int32_t contextId, NativeString *module, const char *eventType, void* event, NativeString *extra);
KRAKEN_EXPORT_C
Screen *createScreen(double width, double height);

KRAKEN_EXPORT_C
void registerDartMethods(uint64_t *methodBytes, int32_t length);

KRAKEN_EXPORT_C
void registerPluginSource(NativeString* code, const char *pluginName);

#if ENABLE_DEBUGGER
KRAKEN_EXPORT_C
void attachInspector(int32_t contextId);
KRAKEN_EXPORT_C
void registerInspectorDartMethods(uint64_t *methodBytes, int32_t length);
KRAKEN_EXPORT_C
void dispatchInspectorTask(int32_t contextId, int32_t taskId);
#endif

#endif // KRAKEN_BRIDGE_EXPORT_H
