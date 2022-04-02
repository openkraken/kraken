/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_EXPORT_H
#define KRAKEN_BRIDGE_EXPORT_H

#include <thread>

#define KRAKEN_EXPORT_C extern "C" __attribute__((visibility("default"))) __attribute__((used))
#define KRAKEN_EXPORT __attribute__((__visibility__("default")))

KRAKEN_EXPORT
std::thread::id getUIThreadId();

typedef struct NativeString NativeString;
typedef struct NativeScreen NativeScreen;
typedef struct NativeByteCode NativeByteCode;

struct KrakenInfo;

struct KrakenInfo {
  const char* app_name{nullptr};
  const char* app_version{nullptr};
  const char* app_revision{nullptr};
  const char* system_name{nullptr};
};

typedef void (*Task)(void*);
typedef void (*ConsoleMessageHandler)(void* ctx, const std::string& message, int logLevel);

KRAKEN_EXPORT_C
void initJSPagePool(int poolSize);
KRAKEN_EXPORT_C
void disposePage(int32_t contextId);
KRAKEN_EXPORT_C
int32_t allocateNewPage(int32_t targetContextId);
KRAKEN_EXPORT_C
void* getPage(int32_t contextId);
bool checkPage(int32_t contextId);
bool checkPage(int32_t contextId, void* context);
KRAKEN_EXPORT_C
void evaluateScripts(int32_t contextId, NativeString* code, const char* bundleFilename, int startLine);
KRAKEN_EXPORT_C
void evaluateQuickjsByteCode(int32_t contextId, uint8_t* bytes, int32_t byteLen);
KRAKEN_EXPORT_C
void parseHTML(int32_t contextId, const char* code, int32_t length);
KRAKEN_EXPORT_C
void reloadJsContext(int32_t contextId);
KRAKEN_EXPORT_C
void invokeModuleEvent(int32_t contextId,
                       NativeString* module,
                       const char* eventType,
                       void* event,
                       NativeString* extra);
KRAKEN_EXPORT_C
void registerDartMethods(int32_t contextId, uint64_t* methodBytes, int32_t length);
KRAKEN_EXPORT_C
NativeScreen* createScreen(double width, double height);
KRAKEN_EXPORT_C
KrakenInfo* getKrakenInfo();
KRAKEN_EXPORT_C
void dispatchUITask(int32_t contextId, void* context, void* callback);
KRAKEN_EXPORT_C
void flushUITask(int32_t contextId);
KRAKEN_EXPORT_C
void registerUITask(int32_t contextId, Task task, void* data);
KRAKEN_EXPORT_C
void* getUICommandItems(int32_t contextId);
KRAKEN_EXPORT_C
int64_t getUICommandItemSize(int32_t contextId);
KRAKEN_EXPORT_C
void clearUICommandItems(int32_t contextId);
KRAKEN_EXPORT_C
void registerContextDisposedCallbacks(int32_t contextId, Task task, void* data);
KRAKEN_EXPORT_C
void registerPluginByteCode(uint8_t* bytes, int32_t length, const char* pluginName);
KRAKEN_EXPORT_C
int32_t profileModeEnabled();

KRAKEN_EXPORT
void setConsoleMessageHandler(ConsoleMessageHandler handler);

#endif  // KRAKEN_BRIDGE_EXPORT_H
