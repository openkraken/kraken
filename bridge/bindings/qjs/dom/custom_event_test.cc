/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "event_target.h"
#include "bridge_qjs.h"

TEST(CustomEvent, instanceofEvent) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg, void* data) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto &context = bridge->getContext();
  const char* code = "let customEvent = new CustomEvent('abc', { detail: 'helloworld'});"
                     "console.log(customEvent instanceof Event);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}
