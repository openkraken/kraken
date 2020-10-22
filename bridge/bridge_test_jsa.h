/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BRIDGE_TEST_JSA_H
#define KRAKENBRIDGE_BRIDGE_TEST_JSA_H

#include "bridge.h"
#include "kraken_bridge_test.h"

#ifdef KRAKEN_ENABLE_JSA

namespace kraken {

class JSBridgeTest final {
public:
  explicit JSBridgeTest() = delete;
  explicit JSBridgeTest(JSBridge *bridge);

  /// evaluete JavaScript source code with build-in test frameworks, use in test only.
  bool evaluateTestScripts(const uint16_t* code, size_t codeLength, const char* sourceURL, int startLine);
  void invokeExecuteTest(ExecuteCallback executeCallback);

  std::shared_ptr<Value> executeTestCallback{nullptr};

private:
  /// the pointer of bridge, ownership belongs to JSBridge
  JSBridge *bridge_;
  /// the pointer of JSContext, overship belongs to JSContext
  alibaba::jsa::JSContext *context;
};

} // namespace kraken

#endif
#endif // KRAKENBRIDGE_BRIDGE_TEST_JSA_H
