/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "kraken_test_env.h"
#include "page.h"
#include "include/kraken_bridge.h"

using namespace kraken;

TEST(Context, isValid) {
  auto bridge = TEST_init();
  EXPECT_EQ(bridge->getContext()->isValid(), true);
}

TEST(Context, evalWithError) {
  static bool errorHandlerExecuted = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    EXPECT_STREQ(errmsg,
                 "TypeError: cannot read property 'toString' of null\n"
                 "    at <eval> (file://:1)\n");
  };
  auto bridge = TEST_init(errorHandler);
  const char* code = "let object = null; object.toString();";
  bridge->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
}

TEST(Context, unrejectPromiseError) {
  static bool errorHandlerExecuted = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    EXPECT_STREQ(errmsg,
                 "TypeError: cannot read property 'forceNullError' of null\n"
                 "    at <anonymous> (file://:4)\n"
                 "    at Promise (native)\n"
                 "    at <eval> (file://:6)\n");
  };
  auto bridge = TEST_init(errorHandler);
  const char* code =
      " var p = new Promise(function (resolve, reject) {\n"
      "        var nullObject = null;\n"
      "        // Raise a TypeError: Cannot read property 'forceNullError' of null\n"
      "        var x = nullObject.forceNullError();\n"
      "        resolve();\n"
      "    });\n"
      "\n";
  bridge->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
}

TEST(Context, unrejectPromiseWillTriggerUnhandledRejectionEvent) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    EXPECT_STREQ(errmsg,
                 "TypeError: cannot read property 'forceNullError' of null\n"
                 "    at <anonymous> (file://:12)\n"
                 "    at Promise (native)\n"
                 "    at <eval> (file://:14)\n");
  };
  auto bridge = TEST_init(errorHandler);
  static int logIndex = 0;
  static std::string logs[] = {"error event cannot read property 'forceNullError' of null", "unhandled event {promise: Promise {...}, reason: Error {...}}"};
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(logs[logIndex++].c_str(), message.c_str());
  };

  std::string code = R"(
window.onunhandledrejection = (e) => {
  console.log('unhandled event', e);
};
window.onerror = (e) => {
  console.log('error event', e);
}

var p = new Promise(function (resolve, reject) {
  var nullObject = null;
  // Raise a TypeError: Cannot read property 'forceNullError' of null
  var x = nullObject.forceNullError();
  resolve();
});
)";
  bridge->evaluateScript(code.c_str(), code.size(), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
  EXPECT_EQ(logCalled, true);
  EXPECT_EQ(logIndex, 2);
  kraken::KrakenPage::consoleMessageHandler = nullptr;
}

TEST(Context, handledRejectionWillNotTriggerUnHandledRejectionEvent) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) { errorHandlerExecuted = true; };
  auto bridge = TEST_init(errorHandler);
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "rejected");
  };

  std::string code = R"(
window.addEventListener('unhandledrejection', event => {
  console.log('unhandledrejection fired: ' + event.reason);
});

window.addEventListener('rejectionhandled', event => {
  console.log('rejectionhandled fired: ' + event.reason);
});

function generateRejectedPromise(isEventuallyHandled) {
  // Create a promise which immediately rejects with a given reason.
  var rejectedPromise = Promise.reject('Error at ' +
    new Date().toLocaleTimeString());
  rejectedPromise.catch(() => {
    console.log('rejected');
  });
}

generateRejectedPromise(true);
)";
  bridge->evaluateScript(code.c_str(), code.size(), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
  kraken::KrakenPage::consoleMessageHandler = nullptr;
}

TEST(Context, unhandledRejectionEventWillTriggerWhenNotHandled) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) { errorHandlerExecuted = true; };
  auto bridge = TEST_init(errorHandler);
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };

  std::string code = R"(
window.addEventListener('unhandledrejection', event => {
  console.log('unhandledrejection fired: ' + event.reason);
});

window.addEventListener('rejectionhandled', event => {
  console.log('rejectionhandled fired: ' + event.reason);
});

function generateRejectedPromise(isEventuallyHandled) {
  // Create a promise which immediately rejects with a given reason.
  var rejectedPromise = Promise.reject('Error');
}

generateRejectedPromise(true);
)";
  bridge->evaluateScript(code.c_str(), code.size(), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
  kraken::KrakenPage::consoleMessageHandler = nullptr;
}

TEST(Context, handledRejectionEventWillTriggerWhenUnHandledRejectHandled) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  auto errorHandler = [](int32_t contextId, const char* errmsg) { errorHandlerExecuted = true; };
  auto bridge = TEST_init(errorHandler);
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };

  std::string code = R"(
window.addEventListener('unhandledrejection', event => {
  console.log('unhandledrejection fired: ' + event.reason);
});

window.addEventListener('rejectionhandled', event => {
  console.log('rejectionhandled fired: ' + event.reason);
});

function generateRejectedPromise() {
  // Create a promise which immediately rejects with a given reason.
  var rejectedPromise = Promise.reject('Error');
    // We need to handle the rejection "after the fact" in order to trigger a
    // unhandledrejection followed by rejectionhandled. Here we simulate that
    // via a setTimeout(), but in a real-world system this might take place due
    // to, e.g., fetch()ing resources at startup and then handling any rejected
    // requests at some point later on.
    setTimeout(() => {
      // We need to provide an actual function to .catch() or else the promise
      // won't be considered handled.
      rejectedPromise.catch(() => {});
    });
}

generateRejectedPromise();
)";
  bridge->evaluateScript(code.c_str(), code.size(), "file://", 0);

  TEST_runLoop(bridge->getContext());
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
  kraken::KrakenPage::consoleMessageHandler = nullptr;
}

TEST(Context, unrejectPromiseErrorWithMultipleContext) {
  static bool errorHandlerExecuted = false;
  static int32_t errorCalledCount = 0;
  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    errorCalledCount++;
    EXPECT_STREQ(errmsg,
                 "TypeError: cannot read property 'forceNullError' of null\n"
                 "    at <anonymous> (file://:4)\n"
                 "    at Promise (native)\n"
                 "    at <eval> (file://:6)\n");
  };

  auto bridge = TEST_init(errorHandler);
  auto bridge2 = TEST_allocateNewPage();
  const char* code =
      " var p = new Promise(function (resolve, reject) {\n"
      "        var nullObject = null;\n"
      "        // Raise a TypeError: Cannot read property 'forceNullError' of null\n"
      "        var x = nullObject.forceNullError();\n"
      "        resolve();\n"
      "    });\n"
      "\n";
  bridge->evaluateScript(code, strlen(code), "file://", 0);
  bridge2->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
  EXPECT_EQ(errorCalledCount, 2);
}

TEST(Context, accessGetUICommandItemsAfterDisposed) {
  int32_t contextId;
  {
    auto bridge = TEST_init();
    contextId = bridge->getContext()->getContextId();
  }

  EXPECT_EQ(getUICommandItems(contextId), nullptr);
}

TEST(Context, disposeContext) {
  initJSPagePool(1024 * 1024);
  TEST_mockDartMethods(0, nullptr);
  uint32_t contextId = 0;
  auto bridge = static_cast<kraken::KrakenPage*>(getPage(contextId));
  static bool disposed = false;
  bridge->disposeCallback = [](kraken::KrakenPage* bridge) { disposed = true; };
  disposePage(bridge->getContext()->getContextId());
  EXPECT_EQ(disposed, true);
}

TEST(Context, window) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };

  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  };
  auto bridge = TEST_init(errorHandler);
  const char* code = "console.log(window == globalThis)";
  bridge->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Context, windowInheritEventTarget) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ƒ () ƒ () ƒ () true");
  };

  auto errorHandler = [](int32_t contextId, const char* errmsg) {
    errorHandlerExecuted = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  };
  auto bridge = TEST_init(errorHandler);
  const char* code = "console.log(window.addEventListener, addEventListener, globalThis.addEventListener, window.addEventListener === addEventListener)";
  bridge->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Context, evaluateByteCode) {
  static bool errorHandlerExecuted = false;
  static bool logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "Arguments {0: 1, 1: 2, 2: 3, 3: 4, callee: ƒ (), length: 4}");
  };

  auto errorHandler = [](int32_t contextId, const char* errmsg) { errorHandlerExecuted = true; };
  auto bridge = TEST_init(errorHandler);
  const char* code = "function f() { console.log(arguments)} f(1,2,3,4);";
  size_t byteLen;
  uint8_t* bytes = bridge->dumpByteCode(code, strlen(code), "vm://", &byteLen);
  bridge->evaluateByteCode(bytes, byteLen);

  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
}

TEST(jsValueToNativeString, utf8String) {
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {});
  JSValue str = JS_NewString(bridge->getContext()->ctx(), "helloworld");
  std::unique_ptr<kraken::NativeString> nativeString = kraken::jsValueToNativeString(bridge->getContext()->ctx(), str);
  EXPECT_EQ(nativeString->length, 10);
  uint8_t expectedString[10] = {104, 101, 108, 108, 111, 119, 111, 114, 108, 100};
  for (int i = 0; i < 10; i++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string + i));
  }
  JS_FreeValue(bridge->getContext()->ctx(), str);
}

TEST(jsValueToNativeString, unicodeChinese) {
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {});
  JSValue str = JS_NewString(bridge->getContext()->ctx(), "这是你的优乐美");
  std::unique_ptr<kraken::NativeString> nativeString = kraken::jsValueToNativeString(bridge->getContext()->ctx(), str);
  std::u16string expectedString = u"这是你的优乐美";
  EXPECT_EQ(nativeString->length, expectedString.size());
  for (int i = 0; i < nativeString->length; i++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string + i));
  }
  JS_FreeValue(bridge->getContext()->ctx(), str);
}

TEST(jsValueToNativeString, emoji) {
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {});
  JSValue str = JS_NewString(bridge->getContext()->ctx(), "……🤪");
  std::unique_ptr<kraken::NativeString> nativeString = kraken::jsValueToNativeString(bridge->getContext()->ctx(), str);
  std::u16string expectedString = u"……🤪";
  EXPECT_EQ(nativeString->length, expectedString.length());
  for (int i = 0; i < nativeString->length; i++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string + i));
  }
  JS_FreeValue(bridge->getContext()->ctx(), str);
}
