/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BRIDGE_TEST_JSC_H
#define KRAKENBRIDGE_BRIDGE_TEST_JSC_H

#include "bridge_jsc.h"
#include "kraken_bridge_test.h"

namespace kraken {

class JSBridgeTest final {
public:
  explicit JSBridgeTest() = delete;
  explicit JSBridgeTest(JSBridge *bridge);

  ~JSBridgeTest() {
    if (executeTestCallback != nullptr) {
      JSValueUnprotect(context->context(), executeTestCallback);
    }
  }

  /// evaluete JavaScript source code with build-in test frameworks, use in test only.
  bool evaluateTestScripts(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine);
  void invokeExecuteTest(ExecuteCallback executeCallback);

  JSValueRef executeTestCallback{nullptr};

private:
  /// the pointer of bridge, ownership belongs to JSBridge
  JSBridge *bridge_;
  /// the pointer of JSContext, overship belongs to JSContext
  const std::unique_ptr<binding::jsc::JSContext> &context;
};

} // namespace kraken

#endif // KRAKENBRIDGE_BRIDGE_TEST_JSC_H
