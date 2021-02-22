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

  NativeString *clone() {
    NativeString *newNativeString = new NativeString();
    uint16_t *newString = new uint16_t[length];

    for (size_t i = 0; i < length; i++) {
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
  UICommandItem(int32_t id, int32_t type, NativeString args_01, NativeString args_02, void *nativePtr)
    : type(type),
      string_01(reinterpret_cast<int64_t>(args_01.string)),
      args_01_length(args_01.length),
      string_02(reinterpret_cast<int64_t>(args_02.string)),
      args_02_length(args_02.length),
      id(id),
      nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  UICommandItem(int32_t id, int32_t type, NativeString args_01, void *nativePtr)
    : type(type),
      string_01(reinterpret_cast<int64_t>(args_01.string)),
      args_01_length(args_01.length),
      id(id),
      nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  UICommandItem(int32_t id, int32_t type, void *nativePtr) : type(type), id(id), nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  int32_t type;
  int32_t id;
  int32_t args_01_length{0};
  int32_t args_02_length{0};
  int64_t string_01{0};
  int64_t string_02{0};
  int64_t nativePtr{0};
};

KRAKEN_EXPORT
void initJSContextPool(int poolSize);
KRAKEN_EXPORT
void disposeContext(int32_t contextId);
KRAKEN_EXPORT
int32_t allocateNewContext();

KRAKEN_EXPORT
KrakenInfo *getKrakenInfo();

KRAKEN_EXPORT
UICommandItem *getUICommandItems(int32_t contextId);
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
void flushUICommandCallback();

KRAKEN_EXPORT
void reloadJsContext(int32_t contextId);
KRAKEN_EXPORT
void invokeEventListener(int32_t contextId, int32_t type, NativeString *code);
KRAKEN_EXPORT
Screen *createScreen(double width, double height);

KRAKEN_EXPORT
void registerDartMethods(uint64_t *methodBytes, int32_t length);

#endif // KRAKEN_BRIDGE_EXPORT_H
