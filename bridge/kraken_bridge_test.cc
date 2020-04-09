/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge_test.h"
#include "bridge_test.h"
#include "dart_methods.h"
#include "jsa.h"
#include "testframework.h"
#include <atomic>
#include <iostream>

std::unique_ptr<kraken::JSBridgeTest> bridgeTest;
std::atomic<bool> inited{false};

void initTestFramework() {
  if (inited == true) return;
  auto bridge = static_cast<kraken::JSBridge *>(getBridge());
  bridgeTest = std::make_unique<kraken::JSBridgeTest>(bridge);
  inited = true;
}

int8_t evaluateTestScripts(const char *code, const char *bundleFilename, int startLine) {
  if (inited == false) return 0;

  return bridgeTest->evaluateTestScripts(std::string(code), std::string(bundleFilename), startLine);
}

void registerJSError(OnJSError jsError) {
  kraken::registerJSError(jsError);
}

void executeTest(ExecuteCallback executeCallback) {
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
