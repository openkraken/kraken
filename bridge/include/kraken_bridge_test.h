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
void initTestFramework();
KRAKEN_EXPORT
int8_t evaluateTestScripts(const char *code, const char *bundleFilename, int startLine);

using ExecuteCallback = void *(*)(const char *status);

KRAKEN_EXPORT
void executeTest(ExecuteCallback executeCallback);

KRAKEN_EXPORT
void registerJSError(OnJSError jsError);

using RefreshPaintCallback = void (*)(void *callbackContext, void *context, int32_t contextIndex, const char *);
using RefreshPaint = void (*)(void *callbackContext, void *context, int32_t contextIndex, RefreshPaintCallback callback);
KRAKEN_EXPORT
void registerRefreshPaint(RefreshPaint refreshPaint);

using MatchImageSnapshotCallback = void (*)(void *callbackContext, void *context, int32_t contextIndex, int8_t);
using MatchImageSnapshot = void (*)(void *callbackContext, void *context, int32_t contextIndex, uint8_t *bytes, int32_t length, const char *name,
                                    MatchImageSnapshotCallback callback);
KRAKEN_EXPORT
void registerMatchImageSnapshot(MatchImageSnapshot matchImageSnapshot);

using Environment = const char *(*)();

KRAKEN_EXPORT
void registerEnvironment(Environment environment);

#endif