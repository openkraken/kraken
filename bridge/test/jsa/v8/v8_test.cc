/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "jsa.h"
#include "v8/v8_implementation.h"
#include "gtest/gtest.h"
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
  // TODO verify symbol toString
  //  auto str = result.getSymbol(*context).toString(*context);
}

TEST(V8Context, V8ObjectValue_getProperty) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value result = context->evaluateJavaScript("({name: 1})", "", 0);
  EXPECT_EQ(result.isObject(), true);
  jsa::Object obj = result.getObject(*context);
  jsa::Value name = obj.getProperty(*context, "name");
  EXPECT_EQ(name.isNumber(), true);
}

TEST(V8Context, V8ObjectValue_GetGlobalProperty) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Object global = context->global();
  global.setProperty(*context, "name", jsa::Value(1));
  jsa::Value result = context->evaluateJavaScript("this.name = 2", "", 0);
  EXPECT_EQ(result.isNumber(), true);
  EXPECT_EQ(result.getNumber(), 2);
  jsa::Object newGlobal = context->global();
  jsa::Value name = global.getProperty(*context, "name");
  EXPECT_EQ(name.isNumber(), true);
  EXPECT_EQ(name.getNumber(), 2);
}

TEST(V8Context, V8ObjectValue_setProperty) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value value = jsa::Value(*context, jsa::Object(*context));
  value.getObject(*context).setProperty(*context, "name", jsa::Value(1));
  EXPECT_EQ(value.isObject(), true);
  jsa::Value name = value.getObject(*context).getProperty(*context, "name");
  EXPECT_EQ(name.isNumber(), true);
  EXPECT_EQ(name.getNumber(), 1);
  value.getObject(*context).setProperty(*context, "age", jsa::Value(10));
  jsa::Value age = value.getObject(*context).getProperty(*context, "age");
  EXPECT_EQ(age.isNumber(), true);
  EXPECT_EQ(age.getNumber(), 10);
  jsa::Object object = jsa::Object(*context);
  object.setProperty(*context, "test",
                     jsa::String::createFromUtf8(*context, "helloworld"));
  value.getObject(*context).setProperty(*context, "inner", object);
  jsa::Value helloworld = value.getObject(*context)
                              .getProperty(*context, "inner")
                              .getObject(*context)
                              .getProperty(*context, "test");
  EXPECT_EQ(helloworld.getString(*context).utf8(*context), "helloworld");
}

TEST(V8Context, V8ObjectValue_hasProperty) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value value = context->evaluateJavaScript("({name: '12345'})", "", 0);
  EXPECT_EQ(value.isObject(), true);
  EXPECT_EQ(value.getObject(*context).hasProperty(*context, "name"), true);
  EXPECT_EQ(value.getObject(*context).hasProperty(
                *context, jsa::String::createFromUtf8(*context, "name")),
            true);
  EXPECT_EQ(value.getObject(*context).hasProperty(
                *context, jsa::PropNameID::forAscii(*context, "name")),
            true);
}

TEST(V8Context, getPropertyNames) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value value =
      context->evaluateJavaScript("({name: '12345', age: 20})", "", 0);
  jsa::Array names = value.getObject(*context).getPropertyNames(*context);
  size_t length = names.size(*context);
  EXPECT_EQ(length, 2);
  EXPECT_EQ(
      names.getValueAtIndex(*context, 0).getString(*context).utf8(*context),
      "name");
  EXPECT_EQ(
      names.getValueAtIndex(*context, 1).getString(*context).utf8(*context),
      "age");
}

TEST(V8Context, global) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  auto global = context->global();
  global.setProperty(*context, "helloworld", "12345");
  jsa::Value result = context->evaluateJavaScript("global.helloworld", "", 0);
  EXPECT_EQ(result.isString(), true);
  EXPECT_EQ(result.getString(*context).utf8(*context), "12345");
}

TEST(V8Context, global_with_none_global_var) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  auto global = context->global();
  global.setProperty(*context, "helloworld", "12345");
  jsa::Value result = context->evaluateJavaScript("helloworld", "", 0);
  EXPECT_EQ(result.isString(), true);
  EXPECT_EQ(result.getString(*context).utf8(*context), "12345");
}

TEST(V8Context, propIdStrictEquals) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::PropNameID &&left = jsa::PropNameID::forAscii(*context, "1234");
  jsa::PropNameID &&right = jsa::PropNameID::forAscii(*context, "1234");
  EXPECT_EQ(left.compare(*context, left, right), true);
}

TEST(V8Context, symbolStrictEquals) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value left = context->evaluateJavaScript("Symbol.for('1234')", "", 0);
  jsa::Value right = context->evaluateJavaScript("Symbol.for('1234')", "", 0);
  EXPECT_EQ(jsa::Value::strictEquals(*context, left, right), true);
}

TEST(V8Context, stringStrictEquals) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value left = jsa::String::createFromAscii(*context, "helloworld");
  jsa::Value right = context->evaluateJavaScript("'helloworld'", "", 0);
  EXPECT_EQ(jsa::Value::strictEquals(*context, left, right), true);
}

TEST(V8Context, array_get) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value result = context->evaluateJavaScript("[1,2,3,4]", "", 0);
  EXPECT_EQ(result.getObject(*context).isArray(*context), true);
  jsa::Array array = result.getObject(*context).getArray(*context);
  jsa::Value first = array.getValueAtIndex(*context, 0);
  EXPECT_EQ(first.isNumber(), true);
  EXPECT_EQ(first.getNumber(), 1);

  size_t length = array.length(*context);
  EXPECT_EQ(length, 4);
}

TEST(V8Context, array_set) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value result = context->evaluateJavaScript("a = [1,2,3,4]", "", 0);
  jsa::Array array = result.getObject(*context).getArray(*context);
  size_t length = array.length(*context);
  EXPECT_EQ(length, 4);
  array.setValueAtIndex(*context, 3, jsa::Value(10));
  jsa::Object global = context->global();
  EXPECT_EQ(global.getProperty(*context, "a")
                .getObject(*context)
                .getArray(*context)
                .getValueAtIndex(*context, 3)
                .getNumber(),
            10);
}

TEST(V8Context, arrayBuffer_uint8) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value value =
      context->evaluateJavaScript("new Int8Array([1,2,3,4,5]).buffer", "", 0);
  jsa::ArrayBuffer buffer = value.getObject(*context).getArrayBuffer(*context);
  EXPECT_EQ(buffer.isArrayBuffer(*context), true);
  uint8_t *data = static_cast<uint8_t *>(buffer.data(*context));
  EXPECT_EQ(data[0], 1);
  EXPECT_EQ(data[1], 2);
  EXPECT_EQ(data[2], 3);
  EXPECT_EQ(data[3], 4);
  EXPECT_EQ(data[4], 5);
  size_t size = buffer.size(*context);
  EXPECT_EQ(size, 5);
}

TEST(V8Context, arrayBuffer_uint16) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value value = context->evaluateJavaScript(
      "new Int16Array([1000, 2000, 3000, 4000, 5000]).buffer", "", 0);
  jsa::ArrayBuffer buffer = value.getObject(*context).getArrayBuffer(*context);
  EXPECT_EQ(buffer.isArrayBuffer(*context), true);
  uint16_t *data = static_cast<uint16_t *>(buffer.data(*context));
  size_t size = buffer.size(*context);
  EXPECT_EQ(size, 10);
  EXPECT_EQ(data[0], 1000);
  EXPECT_EQ(data[1], 2000);
  EXPECT_EQ(data[2], 3000);
  EXPECT_EQ(data[3], 4000);
  EXPECT_EQ(data[4], 5000);
}

TEST(V8Context, instanceof) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value constructor = context->evaluateJavaScript("Object", "", 0);
  jsa::Object obj = jsa::Object(*context);
  obj.instanceOf(*context,
                 constructor.getObject(*context).getFunction(*context));
}

TEST(V8Context, callFunction) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value value =
      context->evaluateJavaScript("function A() {return 11;}; A;", "", 0);
  jsa::Function func = value.getObject(*context).getFunction(*context);
  EXPECT_EQ(func.isFunction(*context), true);
  jsa::Value result = func.call(*context);
  EXPECT_EQ(result.isNumber(), true);
  EXPECT_EQ(result.getNumber(), 11);

  jsa::Object global = context->global();
  jsa::Function a = global.getPropertyAsFunction(*context, "A");
  jsa::Value aResult = a.call(*context);
  EXPECT_EQ(aResult.getNumber(), 11);
}

TEST(V8Context, callFunctionWithArgs) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  context->evaluateJavaScript(R"(
function fibonacci(num) {
  if (num <= 1) return 1;

  return fibonacci(num - 1) + fibonacci(num - 2);
}
)",
                              "", 0);
  jsa::Object global = context->global();
  jsa::Function fibonacci = global.getPropertyAsFunction(*context, "fibonacci");
  jsa::Value result = fibonacci.call(*context, {jsa::Value(10)});
  EXPECT_EQ(result.isNumber(), true);
  EXPECT_EQ(result.getNumber(), 89);
}

TEST(V8Context, callFunctionWithThis) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value result = context->evaluateJavaScript(R"(
function callThis() {
  this.name = 20;
}; callThis;
)",
                                                  "", 0);
  result.getObject(*context).getFunction(*context).call(*context);
  jsa::Object global = context->global();
  jsa::Value name = global.getProperty(*context, "name");
  EXPECT_EQ(name.getNumber(), 20);
}

TEST(V8Context, callAsConstructor) {
  initV8Engine("");
  auto context = std::make_unique<V8Context>();
  jsa::Value result = context->evaluateJavaScript(
      "function F(name) { this.prop = name}; F;", "", 0);
  jsa::Function F = result.getObject(*context).getFunction(*context);
  auto f = F.callAsConstructor(
      *context, {jsa::String::createFromAscii(*context, "helloworld")});
  std::string name = f.getObject(*context)
                         .getProperty(*context, "prop")
                         .getString(*context)
                         .utf8(*context);
  EXPECT_EQ(name, "helloworld");
  jsa::Object global = context->global();
  EXPECT_EQ(global.hasProperty(*context, "prop"), false);
}
