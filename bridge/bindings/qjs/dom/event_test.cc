/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_qjs.h"
#include "event_target.h"
#include "gtest/gtest.h"

TEST(MouseEvent, init) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "10");
    logCalled = true;
  };
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto& context = bridge->getContext();
  const char* code = "let mouseEvent = new MouseEvent('click', {clientX: 10, clientY: 20}); console.log(mouseEvent.clientX);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}
