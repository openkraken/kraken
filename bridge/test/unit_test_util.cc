/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "unit_test_util.h"
#include "bindings/qjs/js_context.h"
#include "include/kraken_bridge.h"

std::unordered_map<int32_t, std::shared_ptr<UnitTestEnv>> unitTestEnvMap;
std::shared_ptr<UnitTestEnv> getUnitTestEnv(int32_t contextUniqueId) {
  if (unitTestEnvMap.count(contextUniqueId) == 0) {
    unitTestEnvMap[contextUniqueId] = std::make_shared<UnitTestEnv>();
  }

  return unitTestEnvMap[contextUniqueId];
}

void registerEventTargetDisposedCallback(int32_t contextUniqueId, OnEventTargetDisposed callback) {
  if (unitTestEnvMap.count(contextUniqueId) == 0) {
    unitTestEnvMap[contextUniqueId] = std::make_shared<UnitTestEnv>();
  }

  unitTestEnvMap[contextUniqueId]->onEventTargetDisposed = callback;
}

void dispatchEvent(kraken::binding::qjs::EventTargetInstance* eventTarget, std::string event) {
  using namespace kraken::binding::qjs;
  std::unique_ptr<NativeString> clickEvent = stringToNativeString(event);
  auto* nativeEvent = new NativeEvent{clickEvent.get()};
  RawEvent rawEvent{reinterpret_cast<uint64_t*>(reinterpret_cast<int64_t*>(nativeEvent))};
  NativeEventTarget::dispatchEventImpl(eventTarget->nativeEventTarget, clickEvent.get(), &rawEvent, 0);
}
