/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "jsa.h"
#include "v8/v8_implementation.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"
#include <iostream>
#include <memory>

using namespace alibaba::jsa_v8;
using namespace alibaba;

TEST(V8Context, undefined) {
  initV8Engine("");
  std::unique_ptr<alibaba::jsa::JSContext> context = createJSContext();
  jsa::Value result = context->evaluateJavaScript("undefined;", "", 0);
  EXPECT_EQ(result.isUndefined(), true);
}

TEST(V8Context, null) {
  initV8Engine("");
  std::unique_ptr<alibaba::jsa::JSContext> context = createJSContext();
  jsa::Value result = context->evaluateJavaScript("null", "", 0);
  EXPECT_EQ(result.isNull(), true);
}

TEST(V8Context, number) {
  initV8Engine("");
  std::unique_ptr<alibaba::jsa::JSContext> context = createJSContext();
  EXPECT_EQ(context->evaluateJavaScript("123456", "", 0).isNumber(), true);
  EXPECT_EQ(context->evaluateJavaScript("new Number('1234')", "", 0).isNumber(),
            true);
  EXPECT_EQ(context->evaluateJavaScript("2.455", "", 0).isNumber(), true);
  EXPECT_EQ(context->evaluateJavaScript("parseInt('42')", "", 0).isNumber(),
            true);
  EXPECT_EQ(
      context->evaluateJavaScript("parseFloat('42.55')", "", 0).isNumber(),
      true);
  EXPECT_EQ(
      context->evaluateJavaScript("parseFloat('x42.55')", "", 0).isNumber(),
      true);
  EXPECT_EQ(context->evaluateJavaScript("NaN", "", 0).isNumber(), true);
}

TEST(V8Context, boolean) {
  initV8Engine("");
  std::unique_ptr<alibaba::jsa::JSContext> context = createJSContext();
  EXPECT_EQ(context->evaluateJavaScript("true", "", 0).isBool(), true);
  EXPECT_EQ(context->evaluateJavaScript("new Boolean('1234')", "", 0).isBool(),
            true);
}

TEST(V8Context, valueRef_undefined) {
  jsa::Value value;
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  v8::Local<v8::Value> ref = context->valueRef(value);
  EXPECT_EQ(ref->IsUndefined(), true);
  EXPECT_EQ(ref->IsNullOrUndefined(), true);
}

TEST(V8Context, valueRef_null) {
  jsa::Value value{nullptr};
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  v8::Local<v8::Value> ref = context->valueRef(value);
  EXPECT_EQ(ref->IsNull(), true);
  EXPECT_EQ(ref->IsNullOrUndefined(), true);
}

TEST(V8Context, valueRef_number) {
  jsa::Value intValue{2};
  jsa::Value doubleValue(2.2);
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  v8::Local<v8::Value> intRef = context->valueRef(intValue);
  v8::Local<v8::Value> doubleRef = context->valueRef(doubleValue);
  EXPECT_EQ(intRef->IsNumber(), true);
  EXPECT_EQ(doubleRef->IsNumber(), true);
}

TEST(V8Context, valueRef_boolean) {
  jsa::Value boolValue{true};
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  v8::Local<v8::Value> boolRef = context->valueRef(boolValue);
  EXPECT_EQ(boolRef->IsBoolean(), true);
}

TEST(V8Context, V8StringValue_newString) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  const std::string str = "helloworld";

  jsa::String string = jsa::String::createFromUtf8(*context, str);
  std::string result = string.utf8(*context);
  EXPECT_EQ(result, str);
}

TEST(V8Context, V8StringValue_evaluateString) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value result = context->evaluateJavaScript("'12345'", "", 0);
  EXPECT_EQ(result.isString(), true);
  std::string resultStr = result.getString(*context).utf8(*context);
  EXPECT_EQ(resultStr, "12345");
}

TEST(V8Context, V8StringValue_evaluateStringObject) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  auto result = context->evaluateJavaScript("new String(12345)", "", 0);
  EXPECT_EQ(result.isString(), true);
  auto resultStr = result.getString(*context).utf8(*context);
  EXPECT_EQ(resultStr, "12345");
}

TEST(V8Context, V8StringValue_createString) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value string = jsa::String::createFromAscii(*context, "helloworld");
  EXPECT_EQ(string.isString(), true);
  auto result = string.getString(*context).utf8(*context);
  EXPECT_EQ(result, "helloworld");
}

TEST(V8Context, V8SymbolValue_evaluateString) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value result = context->evaluateJavaScript("Symbol(1234)", "", 0);
  EXPECT_EQ(result.isSymbol(), true);
  v8::Local<v8::Value> ref = context->valueRef(result);
  EXPECT_EQ(ref->IsSymbol(), true);
  // TODO verify symbol toString
  //  auto str = result.getSymbol(*context).toString(*context);
}

TEST(V8Context, V8ObjectValue_createValue) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value result = context->evaluateJavaScript("({name: 1})", "", 0);
  EXPECT_EQ(result.isObject(), true);
  jsa::Object obj = result.getObject(*context);
  jsa::Value name = obj.getProperty(*context, "name");
  EXPECT_EQ(name.isNumber(), true);
}
