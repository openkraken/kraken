/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BRIDGE_TEST_H
#define KRAKENBRIDGE_BRIDGE_TEST_H

#include "bridge.h"
#include "bridge_test_export.h"

namespace kraken {

class JSBridgeTest final {
public:
  explicit JSBridgeTest() = delete;
  explicit JSBridgeTest(JSBridge *bridge);

  /// evaluete JavaScript source code with build-in test frameworks, use in test only.
  bool evaluateTestScripts(const std::string &script, const std::string &url, int startLine);
  void invokeExecuteTest(ExecuteCallback executeCallback);

private:
  /// the pointer of bridge, ownership belongs to JSBridge
  JSBridge *bridge_;
  /// the pointer of JSContext, overship belongs to JSContext
  alibaba::jsa::JSContext *context;
};

} // namespace kraken

#endif // KRAKENBRIDGE_BRIDGE_TEST_H
