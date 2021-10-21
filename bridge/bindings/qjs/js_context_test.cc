/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "bridge_qjs.h"

TEST(Context, isValid) {
  auto bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {});
  EXPECT_EQ(bridge->getContext()->isValid(), true);
  delete bridge;
}

TEST(Context, evalWithError) {
  bool errorHandlerExecuted = false;
  auto errorHandler = [&errorHandlerExecuted](int32_t contextId, const char *errmsg) {
    errorHandlerExecuted = true;
    EXPECT_STREQ(errmsg, "TypeError: cannot read property 'toString' of null\n"
                         "    at <eval> (file://:1)\n");
  };
  auto bridge = new kraken::JSBridge(0, errorHandler);
  const char* code = "let object = null; object.toString();";
  bridge->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
  delete bridge;
}

TEST(Context, unrejectPromiseError) {
  bool errorHandlerExecuted = false;
  auto errorHandler = [&errorHandlerExecuted](int32_t contextId, const char *errmsg) {
    errorHandlerExecuted = true;
    EXPECT_STREQ(errmsg, "TypeError: cannot read property 'forceNullError' of null\n"
                         "    at <anonymous> (file://:4)\n"
                         "    at Promise (native)\n"
                         "    at <eval> (file://:6)\n");
  };
  auto bridge = new kraken::JSBridge(0, errorHandler);
  const char* code = " var p = new Promise(function (resolve, reject) {\n"
                     "        var nullObject = null;\n"
                     "        // Raise a TypeError: Cannot read property 'forceNullError' of null\n"
                     "        var x = nullObject.forceNullError();\n"
                     "        resolve();\n"
                     "    });\n"
                     "\n";
  bridge->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, true);
  delete bridge;
}

TEST(Context, window) {
  bool errorHandlerExecuted = false;
  static bool logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };

  auto errorHandler = [&errorHandlerExecuted](int32_t contextId, const char *errmsg) {
    errorHandlerExecuted = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  };
  auto bridge = new kraken::JSBridge(0, errorHandler);
  const char* code = "console.log(window == globalThis)";
  bridge->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
  delete bridge;
}

TEST(Context, windowInheritEventTarget) {
  bool errorHandlerExecuted = false;
  static bool logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ƒ () ƒ () ƒ () true");
  };

  auto errorHandler = [&errorHandlerExecuted](int32_t contextId, const char *errmsg) {
    errorHandlerExecuted = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  };
  auto bridge = new kraken::JSBridge(0, errorHandler);
  const char* code = "console.log(window.addEventListener, addEventListener, globalThis.addEventListener, window.addEventListener === addEventListener)";
  bridge->evaluateScript(code, strlen(code), "file://", 0);
  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
  delete bridge;
}

TEST(Context, evaluateByteCode) {
  bool errorHandlerExecuted = false;
  static bool logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "Arguments {0: 1, 1: 2, 2: 3, 3: 4, callee: ƒ (), length: 4}");
  };

  auto errorHandler = [&errorHandlerExecuted](int32_t contextId, const char *errmsg) {
    errorHandlerExecuted = true;
  };
  auto bridge = new kraken::JSBridge(0, errorHandler);
  const char* code = "function f() { console.log(arguments)} f(1,2,3,4);";
  size_t byteLen;
  uint8_t *bytes = bridge->dumpByteCode(code, strlen(code), "vm://", &byteLen);
  bridge->evaluateByteCode(bytes, byteLen);

  EXPECT_EQ(errorHandlerExecuted, false);
  EXPECT_EQ(logCalled, true);
  delete bridge;
}

TEST(jsValueToNativeString, utf8String) {
  auto bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {});
  JSValue str = JS_NewString(bridge->getContext()->ctx(), "helloworld");
  NativeString *nativeString = kraken::binding::qjs::jsValueToNativeString(bridge->getContext()->ctx(), str);
  EXPECT_EQ(nativeString->length, 10);
  uint8_t expectedString[10] = {
      104, 101, 108, 108,
      111, 119, 111, 114,
      108, 100
  };
  for (int i = 0; i < 10; i ++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string + i));
  }
  JS_FreeValue(bridge->getContext()->ctx(), str);
  delete bridge;
}

TEST(jsValueToNativeString, unicodeChinese) {
  auto bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {});
  JSValue str = JS_NewString(bridge->getContext()->ctx(), "这是你的优乐美");
  NativeString *nativeString = kraken::binding::qjs::jsValueToNativeString(bridge->getContext()->ctx(), str);
  std::u16string expectedString = u"这是你的优乐美";
  EXPECT_EQ(nativeString->length, expectedString.size());
  for (int i = 0; i < nativeString->length; i ++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string + i));
  }
  JS_FreeValue(bridge->getContext()->ctx(), str);
  delete bridge;
}

TEST(jsValueToNativeString, emoji) {
  auto bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {});
  JSValue str = JS_NewString(bridge->getContext()->ctx(), "……🤪");
  NativeString *nativeString = kraken::binding::qjs::jsValueToNativeString(bridge->getContext()->ctx(), str);
  std::u16string expectedString = u"……🤪";
  EXPECT_EQ(nativeString->length, expectedString.length());
  for (int i = 0; i < nativeString->length; i ++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string + i));
  }
  JS_FreeValue(bridge->getContext()->ctx(), str);
  delete bridge;
}
