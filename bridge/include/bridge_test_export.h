/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_TEST_EXPORT_H
#define KRAKEN_BRIDGE_TEST_EXPORT_H

#include "bridge_export.h"
#include <cstdint>
#define KRAKEN_EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))

using TestCallback = void (*)(void *);
typedef void *(*Describe)(const char *, void *context, TestCallback callback);

using ItCallback = void (*)(void*, int32_t);
typedef void *(*It)(const char *, void *context, ItCallback callback);
typedef void *(*ItDone)(int32_t, const char*);

typedef void *(*BeforeEach)(void *context, TestCallback callback);
typedef void *(*BeforeAll)(void *context, TestCallback callback);
typedef void *(*AfterEach)(void *context, TestCallback callback);
typedef void *(*AfterAll)(void *context, TestCallback callback);

KRAKEN_EXPORT
void initTestFramework();
KRAKEN_EXPORT
int8_t evaluateTestScripts(const char *code, const char *bundleFilename, int startLine);


KRAKEN_EXPORT
void registerJSError(OnJSError jsError);

#endif