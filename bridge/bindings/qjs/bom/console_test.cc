/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_qjs.h"
#include "console.h"
#include "gtest/gtest.h"

std::once_flag kGlobalClassIdFlag;

TEST(Console, rawPrintShouldWork) {
  static bool logExecuted = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logExecuted = true;
    EXPECT_STREQ(message.c_str(), "1234");
  };
  auto bridge = new kraken::JSBridge(0, [](int32_t contextId, const char *errmsg, void* data) {});
  const char *code = "__kraken_print__('1234', 'info')";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(logExecuted, true);
  delete bridge;
}

TEST(Console, log) {
  static bool logExecuted = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    KRAKEN_LOG(VERBOSE) << message;
    logExecuted = true;
  };
  auto bridge = new kraken::JSBridge(0, [](int32_t contextId, const char *errmsg, void* data) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    exit(1);
  });
  const char *code = "console.log(1234);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(logExecuted, true);
  delete bridge;
}
