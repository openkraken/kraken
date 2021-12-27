/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"
#include "gtest/gtest.h"
#include "kraken_test_env.h"
#include "page.h"

TEST(Element, setAttribute) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "1234");
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
      "console.log(div.getAttribute('hello'))";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Element, instanceofNode) {
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
  const char* code =
      "let div = document.createElement('div');"
      "console.log(div instanceof Node)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Element, instanceofEventTarget) {
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
  const char* code =
      "let div = document.createElement('div');"
      "console.log(div instanceof EventTarget)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Element, stringifyBoundingClientRect) {
  using namespace kraken::binding::qjs;

  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "{\"x\":10,\"y\":20,\"width\":30,\"height\":40,\"top\":10,\"right\":20,\"bottom\":30,\"left\":40}");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();

  NativeBoundingClientRect nativeRect{
      10.0, 20.0, 30.0, 40.0, 10.0, 20.0, 30.0, 40.0,
  };

  auto* clientRect = new BoundingClientRect(context.get(), &nativeRect);
  context->defineGlobalProperty("boundingClient", clientRect->jsObject);

  const char* code = "console.log(JSON.stringify(boundingClient))";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}
