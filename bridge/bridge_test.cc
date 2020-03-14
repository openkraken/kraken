/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_test.h"
#include "testframework.h"

namespace kraken {
using namespace alibaba::jsa;
using namespace kraken::foundation;

bool JSBridgeTest::evaluateTestScripts(const std::string &script, const std::string &url, int startLine) {
  if (!context->isValid()) return false;
  binding::updateLocation(url);
  return !context->evaluateJavaScript(script.c_str(), url.c_str(), startLine).isNull();
}

JSBridgeTest::JSBridgeTest(JSBridge *bridge) : bridge_(bridge), context(bridge->getContext()) {

  initKrakenTestFramework(bridge->getContext());
}

} // namespace kraken