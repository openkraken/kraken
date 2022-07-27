/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

#ifndef WEBF_BRIDGE_EXPORT_H
#define WEBF_BRIDGE_EXPORT_H

#include <cstdint>
#include <thread>

#include "dart_methods.h"
#include "webf_foundation.h"

#define WEBF_EXPORT_C extern "C" __attribute__((visibility("default"))) __attribute__((used))
#define WEBF_EXPORT __attribute__((__visibility__("default")))

WEBF_EXPORT
std::thread::id getUIThreadId();

struct NativeString {
  const uint16_t* string;
  uint32_t length;

  NativeString* clone();
  void free();
};

struct NativeByteCode {
  uint8_t* bytes;
  int32_t length;
};

struct WebFInfo;

struct WebFInfo {
  const char* app_name{nullptr};
  const char* app_version{nullptr};
  const char* app_revision{nullptr};
  const char* system_name{nullptr};
};

struct NativeScreen {
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
  setAttribute,
  removeAttribute,
  cloneNode,
  removeEvent,
  createDocumentFragment,
};

struct WEBF_EXPORT UICommandItem {
  UICommandItem(int32_t id, int32_t type, NativeString args_01, NativeString args_02, void* nativePtr)
      : type(type),
        string_01(reinterpret_cast<int64_t>(args_01.string)),
        args_01_length(args_01.length),
        string_02(reinterpret_cast<int64_t>(args_02.string)),
        args_02_length(args_02.length),
        id(id),
        nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  UICommandItem(int32_t id, int32_t type, NativeString args_01, void* nativePtr)
      : type(type), string_01(reinterpret_cast<int64_t>(args_01.string)), args_01_length(args_01.length), id(id), nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  UICommandItem(int32_t id, int32_t type, void* nativePtr) : type(type), id(id), nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  int32_t type;
  int32_t id;
  int32_t args_01_length{0};
  int32_t args_02_length{0};
  int64_t string_01{0};
  int64_t string_02{0};
  int64_t nativePtr{0};
};

typedef void (*Task)(void*);
typedef void (*ConsoleMessageHandler)(void* ctx, const std::string& message, int logLevel);

WEBF_EXPORT_C
void initJSPagePool(int poolSize);
WEBF_EXPORT_C
void disposePage(int32_t contextId);
WEBF_EXPORT_C
int32_t allocateNewPage(int32_t targetContextId);
WEBF_EXPORT_C
void* getPage(int32_t contextId);
bool checkPage(int32_t contextId);
bool checkPage(int32_t contextId, void* context);
WEBF_EXPORT_C
void evaluateScripts(int32_t contextId, NativeString* code, const char* bundleFilename, int startLine);
WEBF_EXPORT_C
void evaluateQuickjsByteCode(int32_t contextId, uint8_t* bytes, int32_t byteLen);
WEBF_EXPORT_C
void parseHTML(int32_t contextId, const char* code, int32_t length);
WEBF_EXPORT_C
void reloadJsContext(int32_t contextId);
WEBF_EXPORT_C
void invokeModuleEvent(int32_t contextId, NativeString* module, const char* eventType, void* event, NativeString* extra);
WEBF_EXPORT_C
void registerDartMethods(uint64_t* methodBytes, int32_t length);
WEBF_EXPORT_C
NativeScreen* createScreen(double width, double height);
WEBF_EXPORT_C
WebFInfo* getWebFInfo();
WEBF_EXPORT_C
void dispatchUITask(int32_t contextId, void* context, void* callback);
WEBF_EXPORT_C
void flushUITask(int32_t contextId);
WEBF_EXPORT_C
void registerUITask(int32_t contextId, Task task, void* data);
WEBF_EXPORT_C
void flushUICommandCallback();
WEBF_EXPORT_C
UICommandItem* getUICommandItems(int32_t contextId);
WEBF_EXPORT_C
int64_t getUICommandItemSize(int32_t contextId);
WEBF_EXPORT_C
void clearUICommandItems(int32_t contextId);
WEBF_EXPORT_C
void registerContextDisposedCallbacks(int32_t contextId, Task task, void* data);
WEBF_EXPORT_C
void registerPluginByteCode(uint8_t* bytes, int32_t length, const char* pluginName);
WEBF_EXPORT_C
int32_t profileModeEnabled();

WEBF_EXPORT
void setConsoleMessageHandler(ConsoleMessageHandler handler);

#endif  // WEBF_BRIDGE_EXPORT_H
