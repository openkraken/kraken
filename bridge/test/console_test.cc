/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "KOM/console.h"
#include "jsa.h"
#include "gtest/gtest.h"

namespace kraken {
namespace binding {

TEST(console_log, number) {
  std::unique_ptr<alibaba::jsa::JSContext> context = alibaba::jsc::createJSContext();
  bindConsole(context.get());
  const char* code = "console.log(1234)";
  alibaba::jsa::Value returnValue = context->evaluateJavaScript(code, "", 0);
  std::string str = returnValue.asString(*context).utf8(*context);
  EXPECT_EQ(str, "1234");
}

TEST(console_log, string) {
  std::unique_ptr<alibaba::jsa::JSContext> context = alibaba::jsc::createJSContext();
  bindConsole(context.get());
  const char* code = "console.log('12345')";
  alibaba::jsa::Value returnValue = context->evaluateJavaScript(code, "", 0);
  std::string str = returnValue.asString(*context).utf8(*context);
  EXPECT_EQ(str, "'12345'");
}

TEST(console_log, array_with_number) {
  std::unique_ptr<alibaba::jsa::JSContext> context = alibaba::jsc::createJSContext();
  bindConsole(context.get());
  const char* code = "console.log([1,2,3,4,5,6])";
  alibaba::jsa::Value returnValue = context->evaluateJavaScript(code, "", 0);
  std::string str = returnValue.asString(*context).utf8(*context);
  EXPECT_EQ(str, "[1, 2, 3, 4, 5, 6]");
}

TEST(console_log, nest_array) {
  std::unique_ptr<alibaba::jsa::JSContext> context = alibaba::jsc::createJSContext();
  bindConsole(context.get());
  const char* code = "console.log([true,[2,3,4],'5',6])";
  alibaba::jsa::Value returnValue = context->evaluateJavaScript(code, "", 0);
  std::string str = returnValue.asString(*context).utf8(*context);
  EXPECT_EQ(str, "[true, [2, 3, 4], '5', 6]");
}

TEST(console_log, function) {
  std::unique_ptr<alibaba::jsa::JSContext> context = alibaba::jsc::createJSContext();
  bindConsole(context.get());
  const char* code = "function a() {};"
                     "console.log(a);";
  alibaba::jsa::Value returnValue = context->evaluateJavaScript(code, "", 0);
  std::string str = returnValue.asString(*context).utf8(*context);
  EXPECT_EQ(str, "[Function: a]");
}

TEST(console_log, object) {
  std::unique_ptr<alibaba::jsa::JSContext> context = alibaba::jsc::createJSContext();
  bindConsole(context.get());
  const char* code = "console.log({name: 1})";
  alibaba::jsa::Value returnValue = context->evaluateJavaScript(code, "", 0);
  std::string str = returnValue.asString(*context).utf8(*context);
  EXPECT_EQ(str, "{\n"
                 "  'name': 1\n"
                 "}");
}

TEST(console_log, complex_object) {
  std::unique_ptr<alibaba::jsa::JSContext> context = alibaba::jsc::createJSContext();
  bindConsole(context.get());
  const char* code = "function a () {};"
                     "console.log([{"
                        "name: 11,"
                        "func: a"
                     "}, 1, 2, undefined, null, true, false])";
  alibaba::jsa::Value returnValue = context->evaluateJavaScript(code, "", 0);
  std::string str = returnValue.asString(*context).utf8(*context);
  EXPECT_EQ(str, "[{\n"
                "  'name': 11,\n"
                "  'func': [Function: a]\n"
                "}, 1, 2, undefined, null, true, false]");
}

}
}
