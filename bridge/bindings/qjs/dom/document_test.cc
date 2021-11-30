/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_qjs.h"
#include "event_target.h"
#include "gtest/gtest.h"

TEST(Document, createTextNode) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "<div>");
  };
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  const char* code =
      "let div = document.createElement('div');"
      "div.setAttribute('hello', 1234);"
      "document.body.appendChild(div);"
      "let text = document.createTextNode('1234');"
      "div.appendChild(text);"
      "console.log(div);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, instanceofNode) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true true true");
  };
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  const char* code = "console.log(document instanceof Node, document instanceof Document, document instanceof EventTarget)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, createElementShouldWorkWithMultipleContext) {
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  kraken::JSBridge* bridge1;

  const char* code = "(() => { let img = document.createElement('img'); document.body.appendChild(img);  })();";

  {
    auto* bridge = bridge1 = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {});
    auto& context = bridge->getContext();
    bridge->evaluateScript(code, strlen(code), "vm://", 0);
  }

  {
    auto* bridge = new kraken::JSBridge(1, [](int32_t contextId, const char* errmsg) {});
    auto& context = bridge->getContext();
    const char* code = "(() => { let img = document.createElement('img'); document.body.appendChild(img);  })();";
    bridge->evaluateScript(code, strlen(code), "vm://", 0);
    delete bridge;
  }

  bridge1->evaluateScript(code, strlen(code), "vm://", 0);

  delete bridge1;
}
