/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_
#define KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_

#include "bindings/qjs/bom/timer.h"
#include "include/dart_methods.h"

using namespace kraken::binding::qjs;

void TEST_init(ExecutionContext *context);
int32_t TEST_setTimeout(DOMTimerCallbackContext *context, int32_t contextId, AsyncCallback callback, int32_t timeout);
void TEST_runLoop(ExecutionContext *context);

#endif  // KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_
