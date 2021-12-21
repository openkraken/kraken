/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_
#define KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_

#include "bindings/qjs/bom/timer.h"
#include "bindings/qjs/dom/event_target.h"
#include "bindings/qjs/dom/frame_request_callback_collection.h"
#include "include/dart_methods.h"

using namespace kraken::binding::qjs;

void TEST_init(ExecutionContext* context);
void TEST_runLoop(ExecutionContext* context);
void TEST_dispatchEvent(EventTargetInstance* eventTarget, const std::string type);
//void TEST_callNativeMethod(void* nativePtr, NativeValue* returnValue, NativeString* method, int32_t argc, NativeValue* argv);

#endif  // KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_
