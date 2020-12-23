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
void registerTestEnvDartMethods(uint64_t *methodBytes, int32_t length);

#endif
