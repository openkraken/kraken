/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dart_methods.h"
#include "foundation/macros.h"
#include <memory>

namespace kraken {

//std::shared_ptr<DartMethodPointer> methodPointer = std::make_shared<DartMethodPointer>()


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
//  return methodPointer;
}

void registerDartMethods(std::shared_ptr<DartMethodPointer> methodPointer, uint64_t* methodBytes, int32_t length) {

}

void registerTestEnvDartMethods(std::shared_ptr<DartMethodPointer> methodPointer, uint64_t* methodBytes, int32_t length) {

}

#if ENABLE_PROFILE
void registerGetPerformanceEntries(GetPerformanceEntries getPerformanceEntries) {
  methodPointer->getPerformanceEntries = getPerformanceEntries;
}
#endif

}  // namespace kraken
