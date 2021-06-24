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

TEST(jsValueToNativeString, utf8String) {
  auto bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {});
  JSValue str = JS_NewString(bridge->getContext()->context(), "helloworld");
  NativeString *nativeString = kraken::binding::qjs::jsValueToNativeString(bridge->getContext()->context(), str);
  EXPECT_EQ(nativeString->length, 10);
  uint8_t expectedString[10] = {
      104, 101, 108, 108,
      111, 119, 111, 114,
      108, 100
  };
  for (int i = 0; i < 10; i ++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string + i));
  }
}

TEST(jsValueToNativeString, unicodeChinese) {
  auto bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {});
  JSValue str = JS_NewString(bridge->getContext()->context(), "这是你的优乐美");
  NativeString *nativeString = kraken::binding::qjs::jsValueToNativeString(bridge->getContext()->context(), str);
  std::u16string expectedString = u"这是你的优乐美";
  EXPECT_EQ(nativeString->length, expectedString.size());
  for (int i = 0; i < nativeString->length; i ++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string + i));
  }
}

TEST(jsValueToNativeString, emoji) {
  auto bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {});
  JSValue str = JS_NewString(bridge->getContext()->context(), "……🤪");
  NativeString *nativeString = kraken::binding::qjs::jsValueToNativeString(bridge->getContext()->context(), str);
  std::u16string expectedString = u"……🤪";
  EXPECT_EQ(nativeString->length, expectedString.length());
  for (int i = 0; i < nativeString->length; i ++) {
    EXPECT_EQ(expectedString[i], *(nativeString->string + i));
  }
}
