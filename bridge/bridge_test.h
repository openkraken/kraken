/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BRIDGE_TEST_H
#define KRAKENBRIDGE_BRIDGE_TEST_H

#include "bridge.h"

namespace kraken {

class JSBridgeTest final {
public:
  explicit JSBridgeTest() = delete;
  explicit JSBridgeTest(JSBridge *bridge);
  ~JSBridgeTest() = default;

  /// evaluete JavaScript source code with build-in test frameworks, use in test only.
  bool evaluteTestScript(const std::string &script, const std::string &url, int startLine);

private:
  /// the pointer of bridge, ownership belongs to JSBridge
  JSBridge *bridge_;
  /// the pointer of JSContext, overship belongs to JSContext
  alibaba::jsa::JSContext *context;
};

} // namespace kraken

#endif // KRAKENBRIDGE_BRIDGE_TEST_H
