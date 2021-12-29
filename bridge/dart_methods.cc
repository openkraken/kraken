/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dart_methods.h"
#include <memory>
#include "kraken_bridge.h"

namespace kraken {

std::shared_ptr<DartMethodPointer> methodPointer = std::make_shared<DartMethodPointer>();

std::shared_ptr<DartMethodPointer> getDartMethod() {
  std::thread::id currentThread = std::this_thread::get_id();

#ifndef NDEBUG
  // Dart methods can only invoked from Flutter UI threads. Javascript Debugger like Safari Debugger can invoke
  // Javascript methods from debugger thread and will crash the app.
  // @TODO: implement task loops for async method call.
  if (currentThread != getUIThreadId()) {
    // return empty struct to stop further behavior.
    return std::make_shared<DartMethodPointer>();
  }
#endif

  return methodPointer;
}

void registerDartMethods(uint64_t* methodBytes, int32_t length) {
  size_t i = 0;

  methodPointer->invokeModule = reinterpret_cast<InvokeModule>(methodBytes[i++]);
  methodPointer->requestBatchUpdate = reinterpret_cast<RequestBatchUpdate>(methodBytes[i++]);
  methodPointer->reloadApp = reinterpret_cast<ReloadApp>(methodBytes[i++]);
  methodPointer->setTimeout = reinterpret_cast<SetTimeout>(methodBytes[i++]);
  methodPointer->setInterval = reinterpret_cast<SetInterval>(methodBytes[i++]);
  methodPointer->clearTimeout = reinterpret_cast<ClearTimeout>(methodBytes[i++]);
  methodPointer->requestAnimationFrame = reinterpret_cast<RequestAnimationFrame>(methodBytes[i++]);
  methodPointer->cancelAnimationFrame = reinterpret_cast<CancelAnimationFrame>(methodBytes[i++]);
  methodPointer->getScreen = reinterpret_cast<GetScreen>(methodBytes[i++]);
  methodPointer->devicePixelRatio = reinterpret_cast<DevicePixelRatio>(methodBytes[i++]);
  methodPointer->platformBrightness = reinterpret_cast<PlatformBrightness>(methodBytes[i++]);
  methodPointer->toBlob = reinterpret_cast<ToBlob>(methodBytes[i++]);
  methodPointer->flushUICommand = reinterpret_cast<FlushUICommand>(methodBytes[i++]);
  methodPointer->initWindow = reinterpret_cast<InitWindow>(methodBytes[i++]);
  methodPointer->initDocument = reinterpret_cast<InitDocument>(methodBytes[i++]);

#if ENABLE_PROFILE
  methodPointer->getPerformanceEntries = reinterpret_cast<GetPerformanceEntries>(methodBytes[i++]);
#else
  i++;
#endif

  methodPointer->onJsError = reinterpret_cast<OnJSError>(methodBytes[i++]);

  assert_m(i == length, "Dart native methods count is not equal with C++ side method registrations.");
}

void registerTestEnvDartMethods(uint64_t* methodBytes, int32_t length) {
  size_t i = 0;

  methodPointer->onJsError = reinterpret_cast<OnJSError>(methodBytes[i++]);
  methodPointer->matchImageSnapshot = reinterpret_cast<MatchImageSnapshot>(methodBytes[i++]);
  methodPointer->environment = reinterpret_cast<Environment>(methodBytes[i++]);
  methodPointer->simulatePointer = reinterpret_cast<SimulatePointer>(methodBytes[i++]);
  methodPointer->simulateInputText = reinterpret_cast<SimulateInputText>(methodBytes[i++]);

  assert_m(i == length, "Dart native methods count is not equal with C++ side method registrations.");
}

#if ENABLE_PROFILE
void registerGetPerformanceEntries(GetPerformanceEntries getPerformanceEntries) {
  methodPointer->getPerformanceEntries = getPerformanceEntries;
}
#endif

}  // namespace kraken
