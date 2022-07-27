/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

#include "webf_bridge_test.h"
#include "dart_methods.h"

#if WEBF_JSC_ENGINE
#include "bridge_test_jsc.h"
#elif WEBF_QUICK_JS_ENGINE
#include "page_test.h"
#endif
#include <atomic>

std::unordered_map<int, webf::WebFPageTest*> bridgeTestPool = std::unordered_map<int, webf::WebFPageTest*>();

void initTestFramework(int32_t contextId) {
  auto* page = static_cast<webf::WebFPage*>(getPage(contextId));
  auto bridgeTest = new webf::WebFPageTest(page);
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
  webf::registerTestEnvDartMethods(methodBytes, length);
}
