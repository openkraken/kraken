/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"
#include "page.h"
#include "gtest/gtest.h"

TEST(EventTarget, addEventListener) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto* bridge = new kraken::KrakenPage(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  const char* code = "let div = document.createElement('div'); function f(){ console.log(1234); }; div.addEventListener('click', f);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
}

TEST(EventTarget, setNoEventTargetProperties) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "{name: 1}");
  };
  auto* bridge = new kraken::KrakenPage(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  const char* code = "let div = document.createElement('div'); div._a = { name: 1}; console.log(div._a); document.body.appendChild(div);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
}

TEST(EventTarget, propertyEventHandler) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ƒ () 1234");
  };
  auto* bridge = new kraken::KrakenPage(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  const char* code =
      "let div = document.createElement('div'); "
      "div.onclick = function() { return 1234; };"
      "document.body.appendChild(div);"
      "let f = div.onclick;"
      "console.log(f, div.onclick());";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

// TEST(EventTarget, propertyEventOnWindow) {
//  bool static errorCalled = false;
//  bool static logCalled = false;
//  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
//    logCalled = true;
//    EXPECT_STREQ(message.c_str(), "1234");
//  };
//  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
//    KRAKEN_LOG(VERBOSE) << errmsg;
//    errorCalled = true;
//  });
//  auto &context = bridge->getContext();
//  const char* code = "window.onclick = function() { console.log(1234); };"
//                     "window.dispatchEvent(new Event('click'));";
//  bridge->evaluateScript(code, strlen(code), "vm://", 0);
//  delete bridge;
//  EXPECT_EQ(errorCalled, false);
//  EXPECT_EQ(logCalled, true);
//}

TEST(EventTarget, ClassInheritEventTarget) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ƒ () ƒ ()");
  };
  auto* bridge = new kraken::KrakenPage(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  std::string code = std::string(R"(
class Sample extends EventTarget {
  constructor() {
    super();
  }
}

let s = new Sample();
console.log(s.addEventListener, s.removeEventListener)
)");
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}
