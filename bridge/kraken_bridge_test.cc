/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge_test.h"
#include "dart_methods.h"

#if KRAKEN_JSC_ENGINE
#include "bridge_test_jsc.h"
#elif KRAKEN_QUICK_JS_ENGINE
#include "page_test.h"
#endif
#include <atomic>

std::unordered_map<int, kraken::KrakenPageTest*> bridgeTestPool = std::unordered_map<int, kraken::KrakenPageTest*>();

void initTestFramework(int32_t contextId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  auto bridgeTest = new kraken::KrakenPageTest(page);
  bridgeTestPool[contextId] = bridgeTest;
}

int8_t evaluateTestScripts(int32_t contextId, NativeString* code, const char* bundleFilename, int startLine) {
  auto bridgeTest = bridgeTestPool[contextId];
  return bridgeTest->evaluateTestScripts(code->string, code->length, bundleFilename, startLine);
}

void executeTest(int32_t contextId, ExecuteCallback executeCallback) {
  auto bridgeTest = bridgeTestPool[contextId];
  bridgeTest->invokeExecuteTest(executeCallback);
}

void registerTestEnvDartMethods(uint64_t* methodBytes, int32_t length) {
  kraken::registerTestEnvDartMethods(methodBytes, length);
}
