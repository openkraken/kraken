/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "atomic_string.h"
#include <quickjs/quickjs.h>
#include <codecvt>
#include "built_in_string.h"
#include "event_type_names.h"
#include "gtest/gtest.h"
#include "native_string_utils.h"
#include "qjs_engine_patch.h"

using namespace kraken;

using TestCallback = void (*)(JSContext* ctx);

void TestAtomicString(TestCallback callback) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);

  built_in_string::Init(ctx);

  callback(ctx);

  JS_FreeContext(ctx);

  built_in_string::Dispose();
  JS_FreeRuntime(runtime);
}

TEST(AtomicString, Empty) {
  TestAtomicString([](JSContext* ctx) {
    AtomicString atomic_string = AtomicString::Empty(ctx);
    EXPECT_STREQ(atomic_string.ToStdString().c_str(), "");
  });
}

TEST(AtomicString, FromNativeString) {
  TestAtomicString([](JSContext* ctx) {
    auto nativeString = stringToNativeString("helloworld");
    AtomicString value = AtomicString::From(ctx, nativeString.get());

    EXPECT_STREQ(value.ToStdString().c_str(), "helloworld");
  });
}

TEST(AtomicString, CreateFromStdString) {
  TestAtomicString([](JSContext* ctx) {
    AtomicString&& value = AtomicString(ctx, "helloworld");
    EXPECT_STREQ(value.ToStdString().c_str(), "helloworld");
  });
}

TEST(AtomicString, CreateFromJSValue) {
  TestAtomicString([](JSContext* ctx) {
    JSValue string = JS_NewString(ctx, "helloworld");
    AtomicString&& value = AtomicString(ctx, string);
    EXPECT_STREQ(value.ToStdString().c_str(), "helloworld");
    JS_FreeValue(ctx, string);
  });
}

TEST(AtomicString, ToQuickJS) {
  TestAtomicString([](JSContext* ctx) {
    AtomicString&& value = AtomicString(ctx, "helloworld");
    JSValue qjs_value = value.ToQuickJS(ctx);
    const char* buffer = JS_ToCString(ctx, qjs_value);
    EXPECT_STREQ(buffer, "helloworld");
    JS_FreeValue(ctx, qjs_value);
    JS_FreeCString(ctx, buffer);
  });
}

TEST(AtomicString, ToNativeString) {
  TestAtomicString([](JSContext* ctx) {
    AtomicString&& value = AtomicString(ctx, "helloworld");
    auto native_string = value.ToNativeString();
    const uint16_t* p = native_string->string();
    EXPECT_EQ(native_string->length(), 10);

    uint16_t result[10] = {'h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd'};
    for (int i = 0; i < native_string->length(); i++) {
      EXPECT_EQ(result[i], p[i]);
    }
  });
}

TEST(AtomicString, CopyAssignment) {
  TestAtomicString([](JSContext* ctx) {
    AtomicString str = AtomicString(ctx, "helloworld");
    struct P {
      AtomicString str;
    };
    P p{AtomicString::Empty(ctx)};
    p.str = str;
    EXPECT_EQ(p.str == str, true);
  });
}

TEST(AtomicString, MoveAssignment) {
  TestAtomicString([](JSContext* ctx) {
    auto&& str = AtomicString(ctx, "helloworld");
    auto&& str2 = AtomicString(std::move(str));
    EXPECT_STREQ(str2.ToStdString().c_str(), "helloworld");
  });
}

TEST(AtomicString, CopyToRightReference) {
  TestAtomicString([](JSContext* ctx) {
    AtomicString str = AtomicString::Empty(ctx);
    if (1 + 1 == 2) {
      str = AtomicString(ctx, "helloworld");
    }
    EXPECT_STREQ(str.ToStdString().c_str(), "helloworld");
  });
}
