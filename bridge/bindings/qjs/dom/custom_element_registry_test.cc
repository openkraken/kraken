/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "event_target.h"
#include "element.h"
#include "bridge_qjs.h"

TEST(CustomElementRegistry, define) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "sampleElement 20");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto &context = bridge->getContext();
  std::string code = R"(
class SampleElement extends Element {
  constructor() {
    super();
    this.age = 20;
  }

  getName() {
    return 'sampleElement';
  }
}

customElements.define('sample-element', SampleElement);

let element = document.createElement('sample-element');
console.log(element.getName(), element.age);
)";
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}


TEST(CustomElementRegistry, defineMultiInheritElement) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "apple apple");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto &context = bridge->getContext();
  std::string code = R"(
class SampleElement extends Element {
  constructor() {
    super();
    this.age = 20;
  }

  getName() {
    return 'sampleElement';
  }
}

class AppleElement extends SampleElement {
  constructor() {
    super();
    this.name = 'apple';
  }

  getName() {
    return 'apple';
  }
}

customElements.define('apple-element', AppleElement);

let element = document.createElement('apple-element');
console.log(element.getName(), element.name);
)";
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(CustomElementRegistry, isJavaScriptExtensionElementInstance) {
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
  std::string code = R"(
class SampleElement extends Element {
  constructor() {
    super();
    this.age = 20;
  }

  getName() {
    return 'sampleElement';
  }
}

class AppleElement extends SampleElement {
  constructor() {
    super();
    this.name = 'apple';
  }

  getName() {
    return 'apple';
  }
}

customElements.define('apple-element', AppleElement);

let element = document.createElement('apple-element');
window.appleElement = element;
window.AppleElement = AppleElement;
)";
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  JSValue appleElementValue = JS_GetPropertyStr(context->ctx(), context->global(), "appleElement");
  JSValue AppleElementValue = JS_GetPropertyStr(context->ctx(), context->global(), "AppleElement");
  EXPECT_EQ(kraken::binding::qjs::isJavaScriptExtensionElementInstance(context.get(), appleElementValue), true);
  EXPECT_EQ(kraken::binding::qjs::isJavaScriptExtensionElementConstructor(context.get(), AppleElementValue), true);
  JS_FreeValue(context->ctx(), appleElementValue);
  JS_FreeValue(context->ctx(), AppleElementValue);

  delete bridge;
  EXPECT_EQ(errorCalled, false);
}
