/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_patch.h"
#include <codecvt>
#include "gtest/gtest.h"

TEST(JS_ToUnicode, asciiWords) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);
  JSValue value = JS_NewString(ctx, "helloworld");
  uint32_t bufferLength;
  uint16_t* buffer = JS_ToUnicode(ctx, value, &bufferLength);
  std::u16string u16Value = u"helloworld";
  std::u16string bufferString = std::u16string(reinterpret_cast<char16_t*>(buffer), bufferLength);

  EXPECT_EQ(bufferString == u16Value, true);

  JS_FreeValue(ctx, value);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
  delete buffer;
}

TEST(JS_ToUnicode, chineseWords) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);
  JSValue value = JS_NewString(ctx, "a你的名字12345");
  uint32_t bufferLength;
  uint16_t* buffer = JS_ToUnicode(ctx, value, &bufferLength);
  std::u16string u16Value = u"a你的名字12345";
  std::u16string bufferString = std::u16string(reinterpret_cast<char16_t*>(buffer), bufferLength);

  EXPECT_EQ(bufferString == u16Value, true);

  JS_FreeValue(ctx, value);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}

TEST(JS_ToUnicode, emoji) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);
  JSValue value = JS_NewString(ctx, "1😀2");
  uint32_t bufferLength;
  uint16_t* buffer = JS_ToUnicode(ctx, value, &bufferLength);
  std::u16string u16Value = u"1😀2";
  std::u16string bufferString = std::u16string(reinterpret_cast<char16_t*>(buffer), bufferLength);

  EXPECT_EQ(bufferString == u16Value, true);

  JS_FreeValue(ctx, value);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}

TEST(JS_NewUnicodeString, fromAscii) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);
  std::u16string source = u"helloworld";
  JSValue result = JS_NewUnicodeString(runtime, ctx, reinterpret_cast<const uint16_t*>(source.c_str()), source.length());
  const char* str = JS_ToCString(ctx, result);
  EXPECT_STREQ(str, "helloworld");

  JS_FreeCString(ctx, str);
  JS_FreeValue(ctx, result);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}

TEST(JS_NewUnicodeString, fromChieseCode) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);
  std::u16string source = u"a你的名字12345";
  JSValue result = JS_NewUnicodeString(runtime, ctx, reinterpret_cast<const uint16_t*>(source.c_str()), source.length());
  uint32_t length;
  uint16_t* buffer = JS_ToUnicode(ctx, result, &length);
  std::u16string bufferString = std::u16string(reinterpret_cast<const char16_t*>(buffer), length);

  EXPECT_EQ(bufferString == source, true);

  JS_FreeValue(ctx, result);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}
