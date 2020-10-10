/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge_test.h"
#include "bridge_test.h"
#include "dart_methods.h"
#include <atomic>

kraken::JSBridgeTest **bridgeTestPool {nullptr};

void initTestFramework(int32_t contextId) {
  if (bridgeTestPool == nullptr) {
      bridgeTestPool = new kraken::JSBridgeTest*[10];
  }

  auto bridge = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  auto bridgeTest = new kraken::JSBridgeTest(bridge);
  bridgeTestPool[contextId] = bridgeTest;
}

int8_t evaluateTestScripts(int32_t contextId, NativeString *code, const char *bundleFilename, int startLine) {
  auto bridgeTest = bridgeTestPool[contextId];
  return bridgeTest->evaluateTestScripts(code->string, code->length, bundleFilename, startLine);
}

void registerJSError(OnJSError jsError) {
  kraken::registerJSError(jsError);
}

void executeTest(int32_t contextId, ExecuteCallback executeCallback) {
  auto bridgeTest = bridgeTestPool[contextId];
  bridgeTest->invokeExecuteTest(executeCallback);
}

void registerRefreshPaint(RefreshPaint refreshPaint) {
  kraken::registerRefreshPaint(refreshPaint);
}

void registerMatchImageSnapshot(MatchImageSnapshot matchImageSnapshot) {
  kraken::registerMatchImageSnapshot(matchImageSnapshot);
}

void registerEnvironment(Environment environment) {
  kraken::registerEnvironment(environment);
}

void registerSimulatePointer(SimulatePointer simulatePointer) {
  kraken::registerSimulatePointer(simulatePointer);
}
