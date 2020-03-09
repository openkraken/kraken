/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_TEST_EXPORT_H
#define KRAKEN_BRIDGE_TEST_EXPORT_H

#include "bridge_export.h"
#include <cstdint>
#define KRAKEN_EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))

using DescribeCallback = void (*)(void *);
typedef void *(*Describe)(const char *, void *context, DescribeCallback callback);

using ItDone = void (*)();
using ItCallback = void (*)(ItDone done);
typedef void *(*It)(const char *, void *context, ItCallback callback);

KRAKEN_EXPORT
void initTestFramework();
KRAKEN_EXPORT
int8_t evaluteTestScripts(const char *code, const char *bundleFilename, int startLine);


KRAKEN_EXPORT
void registerOnJSError(OnJSError jsError);
KRAKEN_EXPORT
void registerDescribe(Describe describe);
KRAKEN_EXPORT
void registerIt(It it);

#endif