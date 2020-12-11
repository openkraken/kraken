/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_TEST_EXPORT_H
#define KRAKEN_BRIDGE_TEST_EXPORT_H

#include "kraken_bridge.h"
#include <cstdint>
#define KRAKEN_EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))

KRAKEN_EXPORT
void initTestFramework(int32_t contextId);
KRAKEN_EXPORT
int8_t evaluateTestScripts(int32_t contextId, NativeString *code, const char *bundleFilename, int startLine);

using ExecuteCallback = void *(*)(int32_t contextId, NativeString *status);

KRAKEN_EXPORT
void executeTest(int32_t contextId, ExecuteCallback executeCallback);

KRAKEN_EXPORT
void registerJSError(OnJSError jsError);

using RefreshPaintCallback = void (*)(void *callbackContext, int32_t contextId, const char *errmsg);
using RefreshPaint = void (*)(void *callbackContext, int32_t contextId, RefreshPaintCallback callback);
KRAKEN_EXPORT
void registerRefreshPaint(RefreshPaint refreshPaint);

using MatchImageSnapshotCallback = void (*)(void *callbackContext, int32_t contextId, int8_t);
using MatchImageSnapshot = void (*)(void *callbackContext, int32_t contextId, uint8_t *bytes, int32_t length,
                                    NativeString *name,
                                    MatchImageSnapshotCallback callback);
KRAKEN_EXPORT
void registerMatchImageSnapshot(MatchImageSnapshot matchImageSnapshot);

using Environment = const char *(*)();

KRAKEN_EXPORT
void registerEnvironment(Environment environment);

struct MousePointer {
  int32_t contextId;
  double x;
  double y;
  double change;
};

using SimulatePointer = void (*)(MousePointer**, int32_t length);

KRAKEN_EXPORT
void registerSimulatePointer(SimulatePointer simulatePointer);

using SimulateKeyPress = void (*)(NativeString* nativeString);

KRAKEN_EXPORT
void registerSimulateKeyPress(SimulateKeyPress simulateKeyPress);

#endif
