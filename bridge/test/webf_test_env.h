/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_TEST_WEBF_TEST_ENV_H_
#define BRIDGE_TEST_WEBF_TEST_ENV_H_

#include <memory>
#include "bindings/qjs/bom/timer.h"
#include "bindings/qjs/dom/event_target.h"
#include "bindings/qjs/dom/frame_request_callback_collection.h"
#include "foundation/logging.h"
#include "include/dart_methods.h"
#include "page.h"

using namespace webf::binding::qjs;

// Trigger a callbacks before GC free the eventTargets.
using TEST_OnEventTargetDisposed = void (*)(webf::binding::qjs::EventTargetInstance* eventTargetInstance);
struct UnitTestEnv {
  TEST_OnEventTargetDisposed onEventTargetDisposed{nullptr};
};

// Mock dart methods and add async timer to emulate webf environment in C++ unit test.

std::unique_ptr<webf::WebFPage> TEST_init(OnJSError onJsError);
std::unique_ptr<webf::WebFPage> TEST_init();
std::unique_ptr<webf::WebFPage> TEST_allocateNewPage();
void TEST_runLoop(ExecutionContext* context);
void TEST_dispatchEvent(int32_t contextId, EventTargetInstance* eventTarget, const std::string type);
void TEST_invokeBindingMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv);
void TEST_registerEventTargetDisposedCallback(int32_t contextUniqueId, TEST_OnEventTargetDisposed callback);
void TEST_mockDartMethods(OnJSError onJSError);
std::shared_ptr<UnitTestEnv> TEST_getEnv(int32_t contextUniqueId);

#endif  // BRIDGE_TEST_WEBF_TEST_ENV_H_
