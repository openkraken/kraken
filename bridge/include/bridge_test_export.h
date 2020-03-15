/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_TEST_EXPORT_H
#define KRAKEN_BRIDGE_TEST_EXPORT_H

#include "bridge_export.h"
#include <cstdint>
#define KRAKEN_EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))

KRAKEN_EXPORT
void initTestFramework();
KRAKEN_EXPORT
int8_t evaluateTestScripts(const char *code, const char *bundleFilename, int startLine);

using ExecuteCallback = void*(*)(const char* status);

KRAKEN_EXPORT
void executeTest(ExecuteCallback executeCallback);

KRAKEN_EXPORT
void registerJSError(OnJSError jsError);

#endif