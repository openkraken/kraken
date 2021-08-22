/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge_test.h"
#include "dart_methods.h"

#ifdef KRAKEN_ENABLE_JSA
#include "bridge_test_jsa.h"
#elif KRAKEN_JSC_ENGINE
#include "bridge_test_jsc.h"
#endif
#include <atomic>

kraken::JSBridgeTest **bridgeTestPool {nullptr};
std::recursive_mutex bridge_test_mutex_;


void initTestFramework(int32_t contextId) {
  std::lock_guard<std::recursive_mutex> guard(bridge_test_mutex_);

  if (bridgeTestPool == nullptr) {
      bridgeTestPool = new kraken::JSBridgeTest*[10];
  }

  auto bridge = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  auto bridgeTest = new kraken::JSBridgeTest(bridge);
  bridgeTestPool[contextId] = bridgeTest;
}

int8_t evaluateTestScripts(int32_t contextId, NativeString *code, const char *bundleFilename, int startLine) {
  std::lock_guard<std::recursive_mutex> guard(bridge_test_mutex_);
  auto bridgeTest = bridgeTestPool[contextId];
  return bridgeTest->evaluateTestScripts(code->string, code->length, bundleFilename, startLine);
}

void executeTest(int32_t contextId, ExecuteCallback executeCallback) {
  std::lock_guard<std::recursive_mutex> guard(bridge_test_mutex_);
  auto bridgeTest = bridgeTestPool[contextId];
  bridgeTest->invokeExecuteTest(executeCallback);
}

void registerTestEnvDartMethods(int32_t isolateHash, uint64_t *methodBytes, int32_t length) {
  kraken::registerTestEnvDartMethods(isolateHash, methodBytes, length);
}
