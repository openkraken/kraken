/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_
#define KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_

#include <memory>
#include "bindings/qjs/bom/timer.h"
#include "bindings/qjs/dom/event_target.h"
#include "bindings/qjs/dom/frame_request_callback_collection.h"
#include "include/dart_methods.h"
#include "page.h"

using namespace kraken::binding::qjs;

// Mock dart methods and add async timer to emulate kraken environment in C++ unit test.

std::unique_ptr<kraken::KrakenPage> TEST_init(OnJSError onJsError);
std::unique_ptr<kraken::KrakenPage> TEST_init();
std::unique_ptr<kraken::KrakenPage> TEST_allocateNewPage();
void TEST_runLoop(ExecutionContext* context);
void TEST_dispatchEvent(EventTargetInstance* eventTarget, const std::string type);
void TEST_callNativeMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv);

#endif  // KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_
