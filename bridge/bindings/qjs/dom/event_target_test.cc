/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"
#include "gtest/gtest.h"
#include "kraken_test_env.h"
#include "page.h"

TEST(EventTarget, addEventListener) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "1234");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  const char* code = "let div = document.createElement('div'); function f(){ console.log(1234); }; div.addEventListener('click', f); div.dispatchEvent(new Event('click'));";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(EventTarget, removeEventListener) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  const char* code =
      "let div = document.createElement('div'); function f(){ console.log(1234); }; div.addEventListener('click', f); div.removeEventListener('click', f); div.dispatchEvent(new Event('click'));";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(logCalled, false);
}

TEST(EventTarget, setNoEventTargetProperties) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "{name: 1}");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });

  auto& context = bridge->getContext();
  const char* code = "let div = document.createElement('div'); div._a = { name: 1}; console.log(div._a); document.body.appendChild(div);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(EventTarget, propertyEventHandler) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ƒ () 1234");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
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
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(EventTarget, setUnExpectedAttributeEventHandler) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = false; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  const char* code =
      "let div = document.createElement('div'); "
      "div.onclick = function() { return 1234; };"
      "document.body.appendChild(div);"
      "div.onclick = undefined;"
      "div.click()";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, false);
}

TEST(EventTarget, propertyEventOnWindow) {
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
      "window.onclick = function() { console.log(1234); };"
      "window.dispatchEvent(new Event('click'));";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(EventTarget, asyncFunctionCallback) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "done");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  std::string code = R"(
    const img = document.createElement('img');
    img.style.width = '100px';
    img.style.height = '100px';
    img.src = "assets/kraken.png";
    document.body.appendChild(img);
    const img2 = img.cloneNode(false);
    document.body.appendChild(img2);

    let anotherImgHasLoad = false;
    async function loadImg() {
      if (anotherImgHasLoad) {
        console.log('done');
      } else {
        anotherImgHasLoad = true;
      }
    }

    img.addEventListener('load', loadImg);
    img2.addEventListener('load', loadImg);

    img.dispatchEvent(new Event('load'));
    img2.dispatchEvent(new Event('load'));
)";
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(EventTarget, ClassInheritEventTarget) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ƒ () ƒ ()");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
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

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(EventTarget, wontLeakWithStringProperty) {
  auto bridge = TEST_init();
  std::string code =
      "var img = new Image();\n"
      "img.any = '1234'";
  bridge->evaluateScript(code.c_str(), code.size(), "internal://", 0);
}

TEST(EventTarget, globalBindListener) {
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "clicked");
  };
  auto bridge = TEST_init();
  std::string code = "addEventListener('click', () => {console.log('clicked'); }); dispatchEvent(new Event('click'))";
  bridge->evaluateScript(code.c_str(), code.size(), "internal://", 0);
  EXPECT_EQ(logCalled, true);
}

TEST(EventTarget, shouldKeepAtom) {
  auto bridge = TEST_init();
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "2");
  };
  std::string code = "addEventListener('click', () => {console.log(1)});";
  bridge->evaluateScript(code.c_str(), code.size(), "internal://", 0);
  JS_RunGC(bridge->getContext()->runtime());

  std::string code2 = "addEventListener('appear', () => {console.log(2)});";
  bridge->evaluateScript(code2.c_str(), code2.size(), "internal://", 0);

  JS_RunGC(bridge->getContext()->runtime());

  std::string code3 = "(function() { var eeee = new Event('appear'); dispatchEvent(eeee); } )();";
  bridge->evaluateScript(code3.c_str(), code3.size(), "internal://", 0);
  EXPECT_EQ(logCalled, true);
}
