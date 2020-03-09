/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_test_export.h"
#include "bridge_test.h"
#include "dart_methods.h"
#include "jsa.h"
#include "testframework.h"
#include <atomic>
#include <iostream>

std::unique_ptr<kraken::JSBridgeTest> bridgeTest;
std::atomic<bool> hasInjectTestFramework{false};
std::atomic<bool> inited{false};

void initTestFramework() {
  if (inited == true) return;
  auto bridge = static_cast<kraken::JSBridge *>(getBridge());
  bridgeTest = std::make_unique<kraken::JSBridgeTest>(bridge);
  inited = true;
}

int8_t evaluteTestScripts(const char *code, const char *bundleFilename, int startLine) {
  if (inited == false) return 0;

  std::cout << code << std::endl;

  return bridgeTest->evaluteTestScript(std::string(code), std::string(bundleFilename), startLine);
}

void registerOnJSError(OnJSError jsError) {
  kraken::registerOnJSError(jsError);
}

void registerDescribe(Describe describe) {
  kraken::registerDescribe(describe);
}

void registerIt(It it) {
  kraken::registerIt(it);
}

void registerItDone(ItDone itDone) {
  kraken::registerItDone(itDone);
}

void registerBeforeEach(BeforeEach beforeEach) {
  kraken::registerBeforeEach(beforeEach);
}

void registerBeforeAll(BeforeAll beforeAll) {
  kraken::registerBeforeAll(beforeAll);
}

void registerAfterEach(AfterEach afterEach) {
  kraken::registerAfterEach(afterEach);
}

void registerAfterAll(AfterAll afterAll) {
  kraken::registerAfterAll(afterAll);
}
