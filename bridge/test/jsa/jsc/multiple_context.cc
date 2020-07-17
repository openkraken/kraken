/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifdef KRAKEN_JSC_ENGINE

#include "jsa.h"
#include "jsc/jsc_implementation.h"
#include "gtest/gtest.h"
#include <memory>

using namespace alibaba;
using namespace jsc;

namespace {
void normalPrint(alibaba::jsa::JSContext &context, const jsa::JSError &error) {
  std::cerr << error.what() << std::endl;
  FAIL();
}
}

TEST(multiple_context, initJSEngine) {
  std::unique_ptr<alibaba::jsa::JSContext> contextA = createJSContext(0, normalPrint, nullptr);
  std::unique_ptr<alibaba::jsa::JSContext> contextB = createJSContext(0, normalPrint, nullptr);

  contextA->global().setProperty(*contextA, "name", jsa::Value(1));
  EXPECT_EQ(contextB->global().getProperty(*contextB, "name").isUndefined(), true);
  EXPECT_EQ(contextA->global().getProperty(*contextA, "name").isUndefined(), false);
  EXPECT_EQ(contextA->global().getProperty(*contextA, "name").getNumber(), 1);
}

TEST(multiple_context, evaluateString) {
  auto errorPrint = [](alibaba::jsa::JSContext &context, const jsa::JSError &error) {
    EXPECT_STREQ(error.what(), "\nReferenceError: Can't find variable: A\n"
                               "    at global code");
  };

  std::unique_ptr<alibaba::jsa::JSContext> contextA = createJSContext(0, normalPrint, nullptr);
  std::unique_ptr<alibaba::jsa::JSContext> contextB = createJSContext(0, normalPrint, nullptr);
  contextA->evaluateJavaScript("function A() {return 'a';}", "", 0);
  contextB->evaluateJavaScript("A()", "", 0);
}

TEST(multiple_context, hostFunction) {
  auto contextA = std::make_unique<JSCContext>(0, normalPrint, nullptr);
  auto contextB = std::make_unique<JSCContext>(1, normalPrint, nullptr);
  jsa::HostFunctionType callback =
    [](jsa::JSContext &context, const jsa::Value &thisVal,
       const jsa::Value *args,
       size_t count) -> jsa::Value { return jsa::Value(12345); };
  JSA_BINDING_FUNCTION(*contextA, contextA->global(), "helloworld", 0, callback);

  jsa::Function helloworldA = contextA->global().getPropertyAsFunction(*contextA, "helloworld");
  jsa::Value result = helloworldA.call(*contextA);
  EXPECT_EQ(result.getNumber(), 12345);
  EXPECT_EQ(helloworldA.isHostFunction(*contextA), true);

  JSA_BINDING_FUNCTION(*contextB, contextB->global(), "helloworld", 0, callback);
  jsa::Function helloworldB = contextB->global().getPropertyAsFunction(*contextB, "helloworld");
  EXPECT_EQ(helloworldB.isHostFunction(*contextB), true);
  jsa::Value resultB = helloworldB.call(*contextB);
  EXPECT_EQ(resultB.getNumber(), 12345);
}

TEST(multiple_context, hostObject_get) {
  auto contextA = std::make_unique<JSCContext>(0, normalPrint, nullptr);
  auto contextB = std::make_unique<JSCContext>(0, normalPrint, nullptr);
  class User : public jsa::HostObject, std::enable_shared_from_this<User> {
    jsa::Value get(jsa::JSContext &context, const jsa::PropNameID &prop) {
      auto _prop = prop.utf8(context);
      if (_prop == "helloworld") {
        return jsa::Value(12345);
      } else if (_prop == "getName") {
        auto func = jsa::Function::createFromHostFunction(
          context, jsa::PropNameID::forAscii(context, "getName"), 1, getName);
        return jsa::Value(context, func);
      }
      return jsa::Value::undefined();
    }

    static jsa::Value getName(jsa::JSContext &context,
                              const jsa::Value &thisVal, const jsa::Value *args,
                              size_t count) {
      const jsa::Value &name = args[0];
      if (name.getString(context).utf8(context) == "andycall") {
        return jsa::Value(context, jsa::String::createFromAscii(context, "chenghuai.dtc"));
      } else if (name.getString(context).utf8(context) == "wssgcg1213") {
        return jsa::Value(context, jsa::String::createFromAscii(context, "zhuoling.lcl"));
      }
      return jsa::Value::undefined();
    };
  };
  jsa::Object userA =
    jsa::Object::createFromHostObject(*contextA, std::make_shared<User>());
  jsa::Value resultA = userA.getProperty(*contextA, "helloworld");
  EXPECT_EQ(resultA.getNumber(), 12345);
  jsa::Value undefinedA = userA.getProperty(*contextA, "unknown");
  EXPECT_EQ(undefinedA.isUndefined(), true);

  jsa::Function getNameA = userA.getPropertyAsFunction(*contextA, "getName");
  jsa::Value nameA = getNameA.call(*contextA, "andycall");
  EXPECT_EQ(nameA.getString(*contextA).utf8(*contextA), "chenghuai.dtc");

  jsa::Object userB =
    jsa::Object::createFromHostObject(*contextA, std::make_shared<User>());
  jsa::Value resultB = userB.getProperty(*contextA, "helloworld");
  EXPECT_EQ(resultB.getNumber(), 12345);
  jsa::Value undefinedB = userB.getProperty(*contextA, "unknown");
  EXPECT_EQ(undefinedB.isUndefined(), true);

  jsa::Function getNameB = userB.getPropertyAsFunction(*contextA, "getName");
  jsa::Value nameB = getNameB.call(*contextA, "andycall");
  EXPECT_EQ(nameB.getString(*contextA).utf8(*contextA), "chenghuai.dtc");
}


TEST(multiple_context, globalContext) {
  auto contextA = std::make_unique<JSCContext>(0, normalPrint, nullptr);
  auto contextB = std::make_unique<JSCContext>(0, normalPrint, nullptr);
  contextA->evaluateJavaScript("String.prototype.helloworld = 1234", "", 0);
  jsa::Value strA = contextA->evaluateJavaScript("new String('1234');", "", 0);
  EXPECT_EQ(strA.asObject(*contextA).getProperty(*contextA, "helloworld").getNumber(), 1234);

  jsa::Value strB = contextB->evaluateJavaScript("new String('1234');", "", 0);
  EXPECT_EQ(strB.asObject(*contextB).getProperty(*contextB, "helloworld").isNumber(), false);
}

TEST(multiple_context, freeze) {
  auto context = std::make_unique<JSCContext>(0, normalPrint, nullptr);
  EXPECT_EQ(context->isFreeze(), false);
  context->freeze();
  EXPECT_EQ(context->isFreeze(), true);
  context->unfreeze();
  EXPECT_EQ(context->isFreeze(), false);
}


#endif