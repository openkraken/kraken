/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "event_target.h"
#include "gtest/gtest.h"
#include "page.h"
#include "webf_test_env.h"

TEST(MouseEvent, init) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "10");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto context = bridge->getContext();
  const char* code = "let mouseEvent = new MouseEvent('click', {clientX: 10, clientY: 20}); console.log(mouseEvent.clientX);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}
