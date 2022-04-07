/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "atomic_string.h"
#include <quickjs/quickjs.h>
#include <codecvt>
#include "script_value.h"
#include "gtest/gtest.h"

using namespace kraken;

using TestCallback = void (*)(JSContext* ctx);

void TestScriptValue(TestCallback callback) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);

  callback(ctx);

  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}


TEST(ScriptValue, createErrorObject) {
  TestScriptValue([](JSContext* ctx) {
    ScriptValue value = ScriptValue::CreateErrorObject(ctx, "error");
    EXPECT_EQ(JS_IsError(ctx, value.QJSValue()), true);
  });
}

TEST(ScriptValue, CreateJsonObject) {
  TestScriptValue([](JSContext* ctx) {
    std::string code = "{\"name\": 1}";
    ScriptValue value = ScriptValue::CreateJsonObject(ctx, code.c_str(), code.size());
    EXPECT_EQ(value.IsObject(), true);
  });
}

TEST(ScriptValue, Empty) {
  TestScriptValue([](JSContext* ctx) {
    ScriptValue empty = ScriptValue::Empty(ctx);
    EXPECT_EQ(empty.IsEmpty(), true);
  });
}

TEST(ScriptValue, ToString) {
  TestScriptValue([](JSContext* ctx) {
    std::string code = "{\"name\": 1}";
    ScriptValue json = ScriptValue::CreateJsonObject(ctx, code.c_str(), code.size());
    AtomicString string = json.ToString();
    EXPECT_STREQ(string.ToStdString().c_str(), "[object Object]");
  });
}

TEST(ScriptValue, CopyAssignment) {
  TestScriptValue([](JSContext* ctx) {
    std::string code = "{\"name\":1}";
    ScriptValue json = ScriptValue::CreateJsonObject(ctx, code.c_str(), code.size());
    struct P {
      ScriptValue value;
    };
    P p;
    p.value = json;
    EXPECT_STREQ(p.value.ToJSONStringify(nullptr).ToString().ToStdString().c_str(),  code.c_str());
  });
}

TEST(ScriptValue, MoveAssignment) {
  TestScriptValue([](JSContext* ctx) {
    ScriptValue other;
    {
      std::string code = "{\"name\":1}";
      other = ScriptValue::CreateJsonObject(ctx, code.c_str(), code.size());
    }

    EXPECT_STREQ(other.ToJSONStringify(nullptr).ToString().ToStdString().c_str(),  "{\"name\":1}");
  });
}
