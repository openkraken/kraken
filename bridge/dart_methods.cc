/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dart_methods.h"
#include "bridge_jsc.h"
#include <memory>

namespace kraken {

    std::unordered_map<int32_t, std::shared_ptr<DartMethodPointer>> methodPointerMap{};

std::shared_ptr<DartMethodPointer> getDartMethod(void* owner) {
    auto bridge = static_cast<kraken::JSBridge*>(owner);
    int32_t isolateHash = bridge->isolateHash;
    if (std::getenv("ENABLE_MULTI_RUNTIME_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_MULTI_RUNTIME_JS_LOG"), "true") == 0) {
        KRAKEN_LOG(VERBOSE) << "getDartMethod(void* owner)  bridge::--> " << bridge << std::endl;
        KRAKEN_LOG(VERBOSE) << "getDartMethod(void* owner)  bridge::-->isolateHash " << bridge->isolateHash << std::endl;
    }

  return getDartMethod(isolateHash);
}

std::shared_ptr<DartMethodPointer> getDartMethod(int32_t isolateHash) {
  std::__thread_id currentThread = std::this_thread::get_id();
    std::shared_ptr<DartMethodPointer> methodPointer;
    if(methodPointerMap[isolateHash] == NULL){
        if (std::getenv("ENABLE_MULTI_RUNTIME_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_MULTI_RUNTIME_JS_LOG"), "true") == 0) {
            KRAKEN_LOG(VERBOSE) << "getDartMethod create isolateHash::--> " << isolateHash << std::endl;
        }
        std::shared_ptr<DartMethodPointer> sharedPtr = std::make_shared<DartMethodPointer>();
        if (std::getenv("ENABLE_MULTI_RUNTIME_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_MULTI_RUNTIME_JS_LOG"), "true") == 0) {
            KRAKEN_LOG(VERBOSE)<< "getDartMethod create std::shared_ptr<DartMethodPointer> sharedPtr:: " << sharedPtr << std::endl;
        }
        methodPointerMap[isolateHash] = sharedPtr;
        methodPointer = methodPointerMap[isolateHash];
    } else {
        methodPointer = methodPointerMap[isolateHash];
    }

#ifndef NDEBUG
  // Dart methods can only invoked from Flutter UI threads. Javascript Debugger like Safari Debugger can invoke
  // Javascript methods from debugger thread and will crash the app.
  // @TODO: implement task loops for async method call.
  if (currentThread != getUIThreadId()) {
    // return empty struct to stop further behavior.
      if (std::getenv("ENABLE_MULTI_RUNTIME_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_MULTI_RUNTIME_JS_LOG"), "true") == 0) {
          KRAKEN_LOG(VERBOSE)<< "getDartMethod(int32_t isolateHash) getUIThreadId():: " << getUIThreadId() << std::endl;
          KRAKEN_LOG(VERBOSE)<< "getDartMethod(int32_t isolateHash) currentThread != getUIThreadId() true:: methodPointer" << methodPointer<< std::endl;
      }
      //@todo !!!!!!
//    return std::make_shared<DartMethodPointer>();
  }
#endif

  return methodPointer;
}

void registerDartMethods(int32_t isolateHash, uint64_t *methodBytes, int32_t length) {
    std::shared_ptr<DartMethodPointer> methodPointer = getDartMethod(isolateHash);
    if (std::getenv("ENABLE_MULTI_RUNTIME_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_MULTI_RUNTIME_JS_LOG"), "true") == 0) {
        KRAKEN_LOG(VERBOSE) << "registerDartMethods: isolateHash---->>> : " << isolateHash << std::endl;
        KRAKEN_LOG(VERBOSE) << "registerDartMethods: methodPointer: " << methodPointer << std::endl;
        KRAKEN_LOG(VERBOSE) << "registerDartMethods: methodBytes:" << methodBytes << std::endl;
    }
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
  methodPointer->initHTML = reinterpret_cast<InitHTML>(methodBytes[i++]);
  methodPointer->initWindow = reinterpret_cast<InitWindow>(methodBytes[i++]);
  methodPointer->initDocument = reinterpret_cast<InitDocument>(methodBytes[i++]);

#if ENABLE_PROFILE
  methodPointer->getPerformanceEntries = reinterpret_cast<GetPerformanceEntries>(methodBytes[i++]);
#else
  i++;
#endif

  methodPointer->onJsError = reinterpret_cast<OnJSError>(methodBytes[i++]);
  methodPointer->getHref = reinterpret_cast<GetHref>(methodBytes[i++]);

  assert_m(i == length, "Dart native methods count is not equal with C++ side method registrations.");
}


void registerTestEnvDartMethods(int32_t isolateHash, uint64_t *methodBytes, int32_t length) {
  size_t i = 0;
  std::shared_ptr<DartMethodPointer> methodPointer = getDartMethod(isolateHash);

  methodPointer->onJsError = reinterpret_cast<OnJSError>(methodBytes[i++]);
  methodPointer->matchImageSnapshot = reinterpret_cast<MatchImageSnapshot>(methodBytes[i++]);
  methodPointer->environment = reinterpret_cast<Environment>(methodBytes[i++]);
  methodPointer->simulatePointer = reinterpret_cast<SimulatePointer>(methodBytes[i++]);
  methodPointer->simulateInputText = reinterpret_cast<SimulateInputText>(methodBytes[i++]);

  assert_m(i == length, "Dart native methods count is not equal with C++ side method registrations.");
}

#if ENABLE_PROFILE
void registerGetPerformanceEntries(int32_t isolateHash, GetPerformanceEntries getPerformanceEntries) {
  std::shared_ptr<DartMethodPointer> methodPointer = getDartMethod(isolateHash);
  methodPointer->getPerformanceEntries = getPerformanceEntries;
}
#endif

} // namespace kraken
