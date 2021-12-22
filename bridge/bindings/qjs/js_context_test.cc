/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "kraken_test_env.h"
#include "page.h"

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
  std::unique_ptr<NativeString> nativeString = kraken::binding::qjs::jsValueToNativeString(bridge->getContext()->ctx(), str);
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
  std::unique_ptr<NativeString> nativeString = kraken::binding::qjs::jsValueToNativeString(bridge->getContext()->ctx(), str);
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
  std::unique_ptr<NativeString> nativeString = kraken::binding::qjs::jsValueToNativeString(bridge->getContext()->ctx(), str);
  std::u16string expectedString = u"……🤪";
  EXPECT_EQ(nativeString->length, expectedString.length());
  for (int i = 0; i < nativeString->length; i++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string + i));
  }
  JS_FreeValue(bridge->getContext()->ctx(), str);
}
