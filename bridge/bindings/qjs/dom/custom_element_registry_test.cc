/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "event_target.h"
#include "bridge_qjs.h"

TEST(CustomElementRegistry, define) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "sampleElement 20");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto &context = bridge->getContext();
  std::string code = R"(
class SampleElement extends Element {
  constructor() {
    super();
    this.age = 20;
  }

  getName() {
    return 'sampleElement';
  }
}

customElements.define('sample-element', SampleElement);

let element = document.createElement('sample-element');
console.log(element.getName(), element.age);
)";
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}
