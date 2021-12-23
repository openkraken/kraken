/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dart_methods.h"
#include "kraken_bridge.h"
#include <memory>

namespace kraken {

std::shared_ptr<UIDartMethodPointer> uiMethodPointer = std::make_shared<UIDartMethodPointer>();

std::shared_ptr<UIDartMethodPointer> getUIDartMethod() {
  return uiMethodPointer;
}

void registerUIDartMethods(uint64_t *methodBytes, int32_t length) {
  size_t i = 0;
  uiMethodPointer->postTaskToInspectorThread = reinterpret_cast<PostTaskToInspectorThread>(methodBytes[i++]);
  assert_m(i == length, "Dart native methods count is not equal with C++ side method registrations.");
}

std::shared_ptr<InspectorDartMethodPointer> inspectorMethodPointer = std::make_shared<InspectorDartMethodPointer>();
std::shared_ptr<InspectorDartMethodPointer> getInspectorDartMethod() {
  assert_m(std::this_thread::get_id() != getUIThreadId(), "inspector dart methods should be called on the inspector thread.");
  return inspectorMethodPointer;
}
void registerInspectorDartMethods(uint64_t *methodBytes, int32_t length) {
  size_t i = 0;
  inspectorMethodPointer->inspectorMessage = reinterpret_cast<InspectorMessage>(methodBytes[i++]);
  inspectorMethodPointer->registerInspectorMessageCallback = reinterpret_cast<RegisterInspectorMessageCallback>(methodBytes[i++]);
  inspectorMethodPointer->postTaskToUiThread = reinterpret_cast<PostTaskToUIThread>(methodBytes[i++]);
}

} // namespace kraken
