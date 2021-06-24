/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "qjs_patch.h"
#include <codecvt>

TEST(JS_ToUnicode, asciiWords) {
  JSRuntime *runtime = JS_NewRuntime();
  JSContext *ctx = JS_NewContext(runtime);
  JSValue value = JS_NewString(ctx, "helloworld");
  uint32_t bufferLength;
  uint16_t *buffer = JS_ToUnicode(ctx, value, &bufferLength);
  std::u16string u16Value = u"helloworld";
  std::u16string bufferString = std::u16string(reinterpret_cast<char16_t *>(buffer), bufferLength);

  EXPECT_EQ(bufferString == u16Value, true);

  JS_FreeValue(ctx, value);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}

TEST(JS_ToUnicode, chineseWords) {
  JSRuntime *runtime = JS_NewRuntime();
  JSContext *ctx = JS_NewContext(runtime);
  JSValue value = JS_NewString(ctx, "a你的名字12345");
  uint32_t bufferLength;
  uint16_t *buffer = JS_ToUnicode(ctx, value, &bufferLength);
  std::u16string u16Value = u"a你的名字12345";
  std::u16string bufferString = std::u16string(reinterpret_cast<char16_t *>(buffer), bufferLength);

  EXPECT_EQ(bufferString == u16Value, true);

  JS_FreeValue(ctx, value);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}

TEST(JS_ToUnicode, emoji) {
  JSRuntime *runtime = JS_NewRuntime();
  JSContext *ctx = JS_NewContext(runtime);
  JSValue value = JS_NewString(ctx, "1😀2");
  uint32_t bufferLength;
  uint16_t *buffer = JS_ToUnicode(ctx, value, &bufferLength);
  std::u16string u16Value = u"1😀2";
  std::u16string bufferString = std::u16string(reinterpret_cast<char16_t *>(buffer), bufferLength);

  EXPECT_EQ(bufferString == u16Value, true);

  JS_FreeValue(ctx, value);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}
