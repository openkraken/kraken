/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_
#define KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_

#include <memory>
#include "core/dart_methods.h"
#include "core/executing_context.h"
#include "core/page.h"
#include "foundation/logging.h"
//
//// Trigger a callbacks before GC free the eventTargets.
// using TEST_OnEventTargetDisposed = void (*)(binding::qjs::EventTargetInstance* eventTargetInstance);
// struct UnitTestEnv {
//  TEST_OnEventTargetDisposed onEventTargetDisposed{nullptr};
//};
//
//// Mock dart methods and add async timer to emulate kraken environment in C++ unit test.
//

namespace kraken {

std::unique_ptr<KrakenPage> TEST_init(OnJSError onJsError);
std::unique_ptr<KrakenPage> TEST_init();
std::unique_ptr<KrakenPage> TEST_allocateNewPage();
void TEST_runLoop(ExecutionContext* context);
void TEST_mockDartMethods(int32_t contextId, OnJSError onJSError);

}  // namespace kraken
// void TEST_dispatchEvent(int32_t contextId, EventTarget* eventTarget, const std::string type);
// void TEST_callNativeMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv);
// void TEST_registerEventTargetDisposedCallback(int32_t contextUniqueId, TEST_OnEventTargetDisposed callback);
// std::shared_ptr<UnitTestEnv> TEST_getEnv(int32_t contextUniqueId);

#endif  // KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_
