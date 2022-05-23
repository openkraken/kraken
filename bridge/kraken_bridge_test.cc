/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

#include "kraken_bridge_test.h"
#include <atomic>
#include "bindings/qjs/native_string_utils.h"
#include "kraken_test_context.h"

std::unordered_map<int, kraken::KrakenTestContext*> testContextPool =
    std::unordered_map<int, kraken::KrakenTestContext*>();

void initTestFramework(int32_t contextId) {
  auto* page = static_cast<kraken::KrakenPage*>(getPage(contextId));
  auto testContext = new kraken::KrakenTestContext(page->GetExecutingContext());
  testContextPool[contextId] = testContext;
}

int8_t evaluateTestScripts(int32_t contextId, void* code, const char* bundleFilename, int startLine) {
  auto testContext = testContextPool[contextId];
  return testContext->evaluateTestScripts(static_cast<kraken::NativeString*>(code)->string(), static_cast<kraken::NativeString*>(code)->length(), bundleFilename, startLine);
}

void executeTest(int32_t contextId, ExecuteCallback executeCallback) {
  auto testContext = testContextPool[contextId];
  testContext->invokeExecuteTest(executeCallback);
}

void registerTestEnvDartMethods(int32_t contextId, uint64_t* methodBytes, int32_t length) {
  auto testContext = testContextPool[contextId];
  testContext->registerTestEnvDartMethods(methodBytes, length);
}
