/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "kraken_test_env.h"

using namespace kraken;

TEST(Document, createElement) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "<div/>");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "console.log(div);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, body) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "<body/>");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code = "console.log(document.body)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, appendParentWillFail) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto context = bridge->GetExecutingContext();
  const char* code = "document.body.appendChild(document.documentElement)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, true);
  EXPECT_EQ(logCalled, false);
}

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
  auto context = bridge->GetExecutingContext();
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

TEST(Document, createComment) {
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
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "div.setAttribute('hello', 1234);"
      "document.body.appendChild(div);"
      "let comment = document.createComment();"
      "div.appendChild(comment);"
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
  auto context = bridge->GetExecutingContext();
  const char* code =
      "console.log(document instanceof Node, document instanceof Document, document instanceof EventTarget)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, FreedByOutOfScope) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = false;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code = "(() => { let img = document.createElement('div');  })();";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, false);
}

TEST(Document, createElementShouldWorkWithMultipleContext) {
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  kraken::KrakenPage* bridge1;

  const char* code = "(() => { let img = document.createElement('img'); document.body.appendChild(img);  })();";

  {
    auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {});
    auto context = bridge->GetExecutingContext();
    bridge->evaluateScript(code, strlen(code), "vm://", 0);
    bridge1 = bridge.release();
  }

  {
    auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {});
    auto context = bridge->GetExecutingContext();
    const char* code = "(() => { let img = document.createElement('img'); document.body.appendChild(img);  })();";
    bridge->evaluateScript(code, strlen(code), "vm://", 0);
  }

  bridge1->evaluateScript(code, strlen(code), "vm://", 0);

  delete bridge1;
}
