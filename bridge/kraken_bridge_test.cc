/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge_test.h"
#include "page_test.h"
#include "bindings/qjs/native_string_utils.h"
#include <atomic>

std::unordered_map<int, kraken::KrakenPageTest*> bridgeTestPool = std::unordered_map<int, kraken::KrakenPageTest*>();

void initTestFramework(int32_t contextId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  auto bridgeTest = new kraken::KrakenPageTest(page);
  bridgeTestPool[contextId] = bridgeTest;
}

int8_t evaluateTestScripts(int32_t contextId, kraken::NativeString* code, const char* bundleFilename, int startLine) {
  auto bridgeTest = bridgeTestPool[contextId];
  return bridgeTest->evaluateTestScripts(code->string, code->length, bundleFilename, startLine);
}

void executeTest(int32_t contextId, ExecuteCallback executeCallback) {
  auto bridgeTest = bridgeTestPool[contextId];
  bridgeTest->invokeExecuteTest(executeCallback);
}

void registerTestEnvDartMethods(int32_t contextId, uint64_t* methodBytes, int32_t length) {
  auto bridgeTest = bridgeTestPool[contextId];
  bridgeTest->registerTestEnvDartMethods(methodBytes, length);
}
