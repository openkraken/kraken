/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "gtest/gtest.h"
#include "kraken_test_env.h"
#include "page.h"

TEST(Window, instanceofEventTarget) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  const char* code = "console.log(window instanceof EventTarget)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Window, requestAnimationFrame) {
  auto bridge = TEST_init();

  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { EXPECT_STREQ(message.c_str(), "456"); };

  std::string code = R"(
requestAnimationFrame(() => {
  console.log('456');
});
)";

  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  TEST_runLoop(bridge->getContext().get());
}

TEST(Window, cancelAnimationFrame) {
  auto bridge = TEST_init();

  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { abort(); };

  std::string code = R"(
let id = requestAnimationFrame(() => {
  console.log('456');
});
cancelAnimationFrame(id);
)";

  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  TEST_runLoop(bridge->getContext().get());
}
