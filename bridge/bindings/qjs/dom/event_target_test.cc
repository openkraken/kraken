/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "event_target.h"
#include "bridge_qjs.h"

TEST(EventTarget, addEventListener) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto &context = bridge->getContext();
  const char* code = "let div = document.createElement('div'); function f(){ console.log(1234); }; div.addEventListener('click', f);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
}

TEST(EventTarget, propertyEventHandler) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto &context = bridge->getContext();
  const char* code = "let div = document.createElement('div'); "
                     "div.onclick = function() { console.log(1234); };"
                     "console.log(div.onclick);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
}

