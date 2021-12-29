/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"
#include "gtest/gtest.h"
#include "kraken_test_env.h"
#include "page.h"

TEST(Document, createTextNode) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "<div>");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
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
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, instanceofNode) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true true true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  const char* code = "console.log(document instanceof Node, document instanceof Document, document instanceof EventTarget)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, createElementShouldWorkWithMultipleContext) {
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  kraken::KrakenPage* bridge1;

  const char* code = "(() => { let img = document.createElement('img'); document.body.appendChild(img);  })();";

  {
    auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {});
    auto& context = bridge->getContext();
    bridge->evaluateScript(code, strlen(code), "vm://", 0);
    bridge1 = bridge.release();
  }

  {
    auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {});
    auto& context = bridge->getContext();
    const char* code = "(() => { let img = document.createElement('img'); document.body.appendChild(img);  })();";
    bridge->evaluateScript(code, strlen(code), "vm://", 0);
  }

  bridge1->evaluateScript(code, strlen(code), "vm://", 0);

  delete bridge1;
}
