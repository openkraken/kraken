/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifdef KRAKEN_JSC_ENGINE

#include "jsa.h"
#include "jsc/jsc_implementation.h"
#include "bindings/KOM/blob.h"
#include "gtest/gtest.h"
#include <memory>

using namespace alibaba;
using namespace jsc;

void normalPrint(const jsa::JSError &error) {
  std::cerr << error.what() << std::endl;
  FAIL();
}

TEST(JSCContext, undefined) {
  std::unique_ptr<alibaba::jsa::JSContext> context = createJSContext(normalPrint);
  jsa::Value result = context->evaluateJavaScript("undefined;", "", 0);
  EXPECT_EQ(result.isUndefined(), true);
}

TEST(JSCContext, null) {
  std::unique_ptr<alibaba::jsa::JSContext> context = createJSContext(normalPrint);
  jsa::Value result = context->evaluateJavaScript("null", "", 0);
  EXPECT_EQ(result.isNull(), true);
}

TEST(JSCContext, number) {
  std::unique_ptr<alibaba::jsa::JSContext> context = createJSContext(normalPrint);
  EXPECT_EQ(context->evaluateJavaScript("123456", "", 0).isNumber(), true);
  EXPECT_EQ(context->evaluateJavaScript("new Number('1234')", "", 0).isObject(),
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

TEST(JSCContext, boolean) {
  std::unique_ptr<alibaba::jsa::JSContext> context = createJSContext(normalPrint);
  EXPECT_EQ(context->evaluateJavaScript("true", "", 0).isBool(), true);
  EXPECT_EQ(
      context->evaluateJavaScript("new Boolean('1234')", "", 0).isObject(),
      true);
}

TEST(JSCContext, newString) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  const std::string str = "helloworld";

  jsa::String string = jsa::String::createFromUtf8(*context, str);
  std::string result = string.utf8(*context);
  EXPECT_EQ(result, str);
}

TEST(JSCContext, evaluateString) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Value result = context->evaluateJavaScript("'12345'", "", 0);
  EXPECT_EQ(result.isString(), true);
  std::string resultStr = result.getString(*context).utf8(*context);
  EXPECT_EQ(resultStr, "12345");
}

TEST(JSCContext, stringCopyRefer) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::String a = jsa::String::createFromAscii(*context, "1234");
}

TEST(JSCContext, evaluateStringObject) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  auto result = context->evaluateJavaScript("new String(12345)", "", 0);
  EXPECT_EQ(result.isObject(), true);
  auto resultStr = result.toString(*context).utf8(*context);
  EXPECT_EQ(resultStr, "12345");
}

TEST(JSCContext, createString) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Value string = jsa::String::createFromAscii(*context, "helloworld");
  EXPECT_EQ(string.isString(), true);
  auto result = string.getString(*context).utf8(*context);
  EXPECT_EQ(result, "helloworld");
}

TEST(JSCContext, getProperty) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Value result = context->evaluateJavaScript("({name: 1})", "", 0);
  EXPECT_EQ(result.isObject(), true);
  jsa::Object obj = result.getObject(*context);
  jsa::Value name = obj.getProperty(*context, "name");
  EXPECT_EQ(name.isNumber(), true);
}

TEST(JSCContext, getGlobalProperty) {
  auto context = std::make_unique<JSCContext>(normalPrint);
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

TEST(JSCContext, setProperty) {
  auto context = std::make_unique<JSCContext>(normalPrint);
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

TEST(JSCContext, hasProperty) {
  auto context = std::make_unique<JSCContext>(normalPrint);
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

TEST(JSCContext, getPropertyNames) {
  auto context = std::make_unique<JSCContext>(normalPrint);
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

TEST(JSCContext, global) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Object global = context->global();
  global.setProperty(*context, "helloworld", "12345");
  jsa::Value result = context->evaluateJavaScript("global.helloworld", "", 0);
  EXPECT_EQ(result.isString(), true);
  EXPECT_EQ(result.getString(*context).utf8(*context), "12345");
}

TEST(JSCContext, global_with_none_global_var) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  auto global = context->global();
  global.setProperty(*context, "helloworld", "12345");
  jsa::Value result = context->evaluateJavaScript("helloworld", "", 0);
  EXPECT_EQ(result.isString(), true);
  EXPECT_EQ(result.getString(*context).utf8(*context), "12345");
}

TEST(JSCContext, propIdStrictEquals) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::PropNameID &&left = jsa::PropNameID::forAscii(*context, "1234");
  jsa::PropNameID &&right = jsa::PropNameID::forAscii(*context, "1234");
  EXPECT_EQ(left.compare(*context, left, right), true);
}

TEST(JSCContext, symbolStrictEquals) {
  //  auto context = std::make_unique<JSCContext>(normalPrint);
  //  jsa::Value left = context->evaluateJavaScript("Symbol.for('1234')", "",
  //  0); jsa::Value right = context->evaluateJavaScript("Symbol.for('1234')",
  //  "", 0); EXPECT_EQ(jsa::Value::strictEquals(*context, left, right), true);
}

TEST(JSCContext, stringStrictEquals) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Value left = jsa::String::createFromAscii(*context, "helloworld");
  jsa::Value right = context->evaluateJavaScript("'helloworld'", "", 0);
  EXPECT_EQ(jsa::Value::strictEquals(*context, left, right), true);
}

TEST(JSCContext, array_get) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Value result = context->evaluateJavaScript("[1,2,3,4]", "", 0);
  EXPECT_EQ(result.getObject(*context).isArray(*context), true);
  jsa::Array array = result.getObject(*context).getArray(*context);
  jsa::Value first = array.getValueAtIndex(*context, 0);
  EXPECT_EQ(first.isNumber(), true);
  EXPECT_EQ(first.getNumber(), 1);

  size_t length = array.length(*context);
  EXPECT_EQ(length, 4);
}

TEST(JSCContext, array_set) {
  auto context = std::make_unique<JSCContext>(normalPrint);
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

TEST(JSCContext, arrayBuffer_uint8) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Value value =
      context->evaluateJavaScript("new Int8Array([1,2,3,4,5]).buffer", "", 0);
  jsa::ArrayBuffer buffer = value.getObject(*context).getArrayBuffer(*context);
  EXPECT_EQ(buffer.isArrayBuffer(*context), true);
  uint8_t *data = buffer.data<uint8_t>(*context);
  EXPECT_EQ(data[0], 1);
  EXPECT_EQ(data[1], 2);
  EXPECT_EQ(data[2], 3);
  EXPECT_EQ(data[3], 4);
  EXPECT_EQ(data[4], 5);
  size_t size = buffer.size(*context);
  EXPECT_EQ(size, 5);
}

TEST(JSCContext, arrayBuffer_uint16) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Value value = context->evaluateJavaScript(
      "new Int16Array([1000, 2000, 3000, 4000, 5000]).buffer", "", 0);
  jsa::ArrayBuffer buffer = value.getObject(*context).getArrayBuffer(*context);
  EXPECT_EQ(buffer.isArrayBuffer(*context), true);
  uint16_t *data = buffer.data<uint16_t>(*context);
  size_t size = buffer.size(*context);
  EXPECT_EQ(size, 10);
  EXPECT_EQ(data[0], 1000);
  EXPECT_EQ(data[1], 2000);
  EXPECT_EQ(data[2], 3000);
  EXPECT_EQ(data[3], 4000);
  EXPECT_EQ(data[4], 5000);
}

TEST(JSCContext, instanceof) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Value constructor = context->evaluateJavaScript("Object", "", 0);
  jsa::Object obj = jsa::Object(*context);
  obj.instanceOf(*context,
                 constructor.getObject(*context).getFunction(*context));
}

TEST(JSCContext, callFunction) {
  auto context = std::make_unique<JSCContext>(normalPrint);
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

TEST(JSCContext, callFunctionWithArgs) {
  auto context = std::make_unique<JSCContext>(normalPrint);
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

TEST(JSCContext, callFunctionWithException) {
  auto errorPrint = [](const jsa::JSError &error) {
    EXPECT_STREQ(error.what(), "\n"
                               "Error: 1234\n"
                               "    at throwAnError");
  };
  auto context = std::make_unique<JSCContext>(errorPrint);
  jsa::Value result = context->evaluateJavaScript(
      R"(function throwAnError() { throw new Error('1234');}; throwAnError; )",
      "", 0);
  jsa::Function throwError = result.getObject(*context).getFunction(*context);
  throwError.call(*context);
}

TEST(JSCContext, callFunctionWithThis) {
  auto context = std::make_unique<JSCContext>(normalPrint);
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

TEST(JSCContext, callAsConstructor) {
  auto context = std::make_unique<JSCContext>(normalPrint);
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

TEST(JSCContext, hostFunction) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::HostFunctionType callback =
      [](jsa::JSContext &context, const jsa::Value &thisVal,
         const jsa::Value *args,
         size_t count) -> jsa::Value { return jsa::Value(12345); };
  jsa::Object object = jsa::Object(*context);
  JSA_BINDING_FUNCTION(*context, object, "helloworld", 0, callback);

  jsa::Function helloworld =
      object.getPropertyAsFunction(*context, "helloworld");
  jsa::Value result = helloworld.call(*context);
  EXPECT_EQ(result.getNumber(), 12345);
}

TEST(JSCContext, hostFunctionWithParams) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::HostFunctionType callback =
      [](jsa::JSContext &context, const jsa::Value &thisVal,
         const jsa::Value *args, size_t count) -> jsa::Value {
    jsa::Object object = jsa::Object(context);
    const jsa::Value &number = args[0];
    object.setProperty(context, "abc", number.getNumber());
    return object;
  };
  jsa::Object object = jsa::Object(*context);
  JSA_BINDING_FUNCTION(*context, object, "getObj", 1, callback);
  jsa::Function getObj = object.getPropertyAsFunction(*context, "getObj");
  jsa::Value result = getObj.call(*context, {jsa::Value(10)});
  EXPECT_EQ(result.isObject(), true);
  EXPECT_EQ(result.getObject(*context).getProperty(*context, "abc").getNumber(),
            10);
}

TEST(JSCContext, hostFunctionWithThis) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::HostFunctionType callback =
      [](jsa::JSContext &context, const jsa::Value &thisVal,
         const jsa::Value *args, size_t count) -> jsa::Value {
    EXPECT_EQ(thisVal.isObject(), true);
    EXPECT_EQ(thisVal.getObject(context)
                  .getProperty(context, "abc")
                  .getString(context)
                  .utf8(context),
              "helloworld");
    return jsa::Value::undefined();
  };
  jsa::Object object = jsa::Object(*context);
  JSA_BINDING_FUNCTION(*context, object, "abc", 0, callback);
  jsa::Function getObj = object.getPropertyAsFunction(*context, "abc");
  jsa::Object thisObject = jsa::Object(*context);
  thisObject.setProperty(*context, "abc", "helloworld");
  getObj.callWithThis(*context, thisObject);
}

TEST(JSCContext, hostFunctionThrowError) {
  auto errorPrint = [](const jsa::JSError &error) {
    EXPECT_STREQ(error.what(), "\n"
                               "Error: ops !!\n"
                               "    at global code");
  };
  auto context = std::make_unique<JSCContext>(errorPrint);
  jsa::HostFunctionType callback =
      [](jsa::JSContext &context, const jsa::Value &thisVal,
         const jsa::Value *args,
         size_t count) -> jsa::Value { throw jsa::JSError(context, "ops !!"); };
  jsa::Object object = jsa::Object(*context);
  JSA_BINDING_FUNCTION(*context, object, "causeError", 0, callback);
  context->global().setProperty(*context, "object", object);
  context->evaluateJavaScript("object.causeError()", "", 0);
}

TEST(JSCContext, isHostFunction) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::HostFunctionType callback =
      [](jsa::JSContext &context, const jsa::Value &thisVal,
         const jsa::Value *args,
         size_t count) -> jsa::Value { return jsa::Value::undefined(); };
  jsa::Object object = jsa::Object(*context);
  jsa::Function func = jsa::Function::createFromHostFunction(
      *context, jsa::PropNameID::forUtf8(*context, "helloworld"), 0, callback);
  EXPECT_EQ(func.isHostFunction(*context), true);
}

TEST(JSCContext, getHostFunction) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::HostFunctionType callback =
      [](jsa::JSContext &context, const jsa::Value &thisVal,
         const jsa::Value *args,
         size_t count) -> jsa::Value { return jsa::Value(1); };
  jsa::Object object = jsa::Object(*context);
  jsa::Function func = jsa::Function::createFromHostFunction(
      *context, jsa::PropNameID::forUtf8(*context, "helloworld"), 0, callback);
  jsa::HostFunctionType other = func.getHostFunction(*context);
  const jsa::Value thisVal = jsa::Value::undefined();
  const jsa::Value *args[0] = {};
  jsa::Value result =
      other(*context, thisVal, reinterpret_cast<const jsa::Value *>(args), 0);
  EXPECT_EQ(result.getNumber(), 1);
}

TEST(JSCContext, hostObject_get) {
  auto context = std::make_unique<JSCContext>(normalPrint);
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
        return jsa::String::createFromAscii(context, "chenghuai.dtc");
      } else if (name.getString(context).utf8(context) == "wssgcg1213") {
        return jsa::String::createFromAscii(context, "zhuoling.lcl");
      }
      return jsa::Value::undefined();
    };
  };
  jsa::Object user =
      jsa::Object::createFromHostObject(*context, std::make_shared<User>());
  jsa::Value result = user.getProperty(*context, "helloworld");
  EXPECT_EQ(result.getNumber(), 12345);
  jsa::Value undefined = user.getProperty(*context, "unknown");
  EXPECT_EQ(undefined.isUndefined(), true);

  jsa::Function getName = user.getPropertyAsFunction(*context, "getName");
  jsa::Value name = getName.call(*context, "andycall");
  EXPECT_EQ(name.getString(*context).utf8(*context), "chenghuai.dtc");
}

TEST(JSCContext, hostObject_set) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  class User : public jsa::HostObject, std::enable_shared_from_this<User> {
    jsa::Value get(jsa::JSContext &context, const jsa::PropNameID &prop) {
      auto _prop = prop.utf8(context);
      if (_prop == "getCallback") {
        return jsa::Value(context, *_callback);
      }
      return jsa::Value::undefined();
    }

    void set(jsa::JSContext &context, const jsa::PropNameID &prop,
             const jsa::Value &value) {
      auto _prop = prop.utf8(context);
      if (_prop == "setCallback") {
        const jsa::Function &f = value.getObject(context).getFunction(context);
        _callback = std::make_shared<jsa::Value>(jsa::Value(context, f));
      }
    }

  public:
    void unbind() { _callback.reset(); }

    std::shared_ptr<jsa::Value> _callback;
  };
  jsa::HostFunctionType callback =
      [](jsa::JSContext &context, const jsa::Value &thisVal,
         const jsa::Value *args,
         size_t count) -> jsa::Value { return jsa::Value(12345); };
  std::shared_ptr<User> u = std::make_shared<User>();
  jsa::Object user = jsa::Object::createFromHostObject(*context, u);
  JSA_BINDING_FUNCTION(*context, user, "setCallback", 1, callback);
  jsa::Function f = user.getProperty(*context, "getCallback")
                        .getObject(*context)
                        .getFunction(*context);
  jsa::Value result = f.call(*context);
  EXPECT_EQ(result.getNumber(), 12345);
  u->unbind();
}

TEST(JSCContext, hostObject_getPropertyNames) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  class User : public jsa::HostObject, std::enable_shared_from_this<User> {
    std::vector<jsa::PropNameID> getPropertyNames(jsa::JSContext &context) {
      std::vector<jsa::PropNameID> propertyNames;
      propertyNames.emplace_back(jsa::PropNameID::forUtf8(context, "connect"));
      propertyNames.emplace_back(jsa::PropNameID::forUtf8(context, "send"));
      propertyNames.emplace_back(jsa::PropNameID::forUtf8(context, "close"));
      return propertyNames;
    }
  };
  std::shared_ptr<User> u = std::make_shared<User>();
  jsa::Object user = jsa::Object::createFromHostObject(*context, u);
  jsa::Array names = user.getPropertyNames(*context);
  EXPECT_EQ(names.size(*context), 3);
  EXPECT_EQ(names.getValueAtIndex(*context, 0).getString(*context).utf8(*context), "connect");
  EXPECT_EQ(names.getValueAtIndex(*context, 1).getString(*context).utf8(*context), "send");
}

TEST(JSCContext, createHostClass) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::HostClassType F = [](jsa::JSContext &context, jsa::Object &constructor, const jsa::Value *args,
                            size_t count) -> jsa::Object {
    constructor.setProperty(context, "abc", jsa::Value(1234));
    return jsa::Value(context, constructor).getObject(context);
  };
  jsa::Function f =
    jsa::Function::createFromHostClass(*context, jsa::PropNameID::forAscii(*context, "F"), 1, F, jsa::Object(*context));
  context->global().setProperty(*context, "F", f);
  jsa::Value result = context->evaluateJavaScript("new F()", "internal:://", 0);
  EXPECT_EQ(result.isObject(), true);
  EXPECT_EQ(result.getObject(*context).getProperty(*context, "abc").getNumber(), 1234);
}

TEST(JSCContext, createHostClassWithInstanceof) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::HostClassType F = [](jsa::JSContext &context, jsa::Object &constructor, const jsa::Value *args,
                            size_t count) -> jsa::Object {
    constructor.setProperty(context, "abc", jsa::Value(1234));
    return jsa::Value(context, constructor).getObject(context);
  };
  jsa::Function f =
    jsa::Function::createFromHostClass(*context, jsa::PropNameID::forAscii(*context, "F"), 1, F, jsa::Object(*context));
  context->global().setProperty(*context, "F", f);
  jsa::Value result = context->evaluateJavaScript("new F();", "internal:://", 0);
  EXPECT_EQ(result.getObject(*context).instanceOf(*context, f), true);
  auto constructor = result.getObject(*context).getProperty(*context, "constructor");
  EXPECT_EQ(constructor.isObject(), true);
}

TEST(JSCContext, isHostClass) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::HostClassType F = [](jsa::JSContext &context, jsa::Object &constructor, const jsa::Value *args,
                            size_t count) -> jsa::Object {
    constructor.setProperty(context, "abc", jsa::Value(1234));
    return jsa::Value(context, constructor).getObject(context);
  };
  jsa::Function f =
    jsa::Function::createFromHostClass(*context, jsa::PropNameID::forAscii(*context, "F"), 1, F, jsa::Object(*context));
  EXPECT_EQ(f.isHostClass(*context), true);

  context->global().setProperty(*context, "f", f);
  jsa::Value f2 = context->evaluateJavaScript("f", "internal://", 0);
  EXPECT_EQ(f2.getObject(*context).getFunction(*context).isHostClass(*context), true);
}

TEST(JSCContext, getHostClass) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::HostClassType F = [](jsa::JSContext &context, jsa::Object &constructor, const jsa::Value *args,
                            size_t count) -> jsa::Object {
    constructor.setProperty(context, "abc", jsa::Value(1234));
    return jsa::Value(context, constructor).getObject(context);
  };
  jsa::Function f =
    jsa::Function::createFromHostClass(*context, jsa::PropNameID::forAscii(*context, "F"), 1, F, jsa::Object(*context));
  EXPECT_EQ(f.isHostClass(*context), true);
  jsa::HostClassType F2 = f.getHostClass(*context);
  jsa::Value args[2] = {jsa::Value(1), jsa::Value(2)};
  jsa::Object constructor = jsa::Object(*context);
  jsa::Object hostValue = F2(*context, constructor, args, 2);
  EXPECT_EQ(hostValue.getProperty(*context, "abc").getNumber(), 1234);
}

TEST(JSCContext, prototypeChain) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Object parentPrototype = jsa::Object(*context);
  parentPrototype.setProperty(*context, "name", "helloworld");

  jsa::HostClassType Parent = [](jsa::JSContext &context, jsa::Object &constructor, const jsa::Value *args,
                                 size_t count) -> jsa::Object {
    constructor.setProperty(context, "abc", jsa::Value(1234));
    EXPECT_EQ(constructor.getProperty(context, "name").getString(context).utf8(context), "helloworld");
    return jsa::Value(context, constructor).getObject(context);
  };
  jsa::Function f =
    jsa::Function::createFromHostClass(*context, jsa::PropNameID::forAscii(*context, "F"), 1, Parent, parentPrototype);
  jsa::Object instance = f.callAsConstructor(*context).getObject(*context);
  jsa::Array names = instance.getPropertyNames(*context);
  EXPECT_EQ(names.length(*context), 2);
  EXPECT_EQ(instance.getProperty(*context, "name").getString(*context).utf8(*context), "helloworld");
  EXPECT_EQ(instance.getProperty(*context, "abc").getNumber(), 1234);
}

TEST(JSCContext, createArrayBuffer) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  const size_t len = 20;
  uint8_t *data = new uint8_t[len];
  for (int i = 0; i < 20; i++) {
    data[i] = i + 1;
  }

  jsa::ArrayBuffer arrayBuffer =
    jsa::ArrayBuffer::createWithUnit8(*context, data, len, [](uint8_t *bytes) { delete bytes; });
  uint8_t *other = arrayBuffer.data<uint8_t>(*context);
  EXPECT_EQ(*other, *data);

  context->global().setProperty(*context, "buffer", arrayBuffer);

  jsa::Value toStringValue = context->evaluateJavaScript("buffer.toString()", "", 0);
  EXPECT_EQ(toStringValue.isString(), true);
  EXPECT_EQ(toStringValue.getString(*context).utf8(*context), "[object ArrayBuffer]");

  jsa::Value rawArray =
      context->evaluateJavaScript("Array.from(new Uint8Array(buffer))", "", 0);
  EXPECT_EQ(rawArray.getObject(*context).isArray(*context), true);
  jsa::Array dataArray = rawArray.getObject(*context).getArray(*context);
  EXPECT_EQ(dataArray.getValueAtIndex(*context, 0).getNumber(), 1);
  EXPECT_EQ(dataArray.getValueAtIndex(*context, 9).getNumber(), 10);
}

TEST(JSCContext, isArrayBufferView) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Value result =
      context->evaluateJavaScript("new Uint8Array([1,2,3,4,5])", "", 0);
  EXPECT_EQ(result.getObject(*context).isArrayBufferView(*context), true);
  jsa::ArrayBufferViewType type =
      result.getObject(*context).getArrayBufferView(*context).getType(*context);
  EXPECT_EQ(type, jsa::ArrayBufferViewType::Uint8Array);
}

TEST(JSCContext, ArrayBufferView_data) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  jsa::Value result =
      context->evaluateJavaScript("new Uint8Array([1,2,3,4,5])", "", 0);
  jsa::ArrayBufferView bufferView =
      result.getObject(*context).getArrayBufferView(*context);
  uint8_t *data = bufferView.data<uint8_t>(*context);
  size_t length = bufferView.size(*context);
  EXPECT_EQ(length, 5);
  EXPECT_EQ(data[0], 1);
  EXPECT_EQ(data[1], 2);
  EXPECT_EQ(data[2], 3);
  EXPECT_EQ(data[3], 4);
  EXPECT_EQ(data[4], 5);
}

TEST(JSCContext, HostObjectAsArgs) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  std::vector<uint8_t> vector = {1, 2, 3, 4, 5};
  jsa::HostFunctionType getBlob =
      [](jsa::JSContext &context, const jsa::Value &thisVal,
         const jsa::Value *args,
         size_t count) -> jsa::Value {
        auto &&object = args[0].getObject(context);
        EXPECT_EQ(object.isHostObject(context), true);
        return jsa::Value::undefined();
      };
  jsa::Function func = jsa::Function::createFromHostFunction(*context, jsa::PropNameID::forAscii(*context, "func"), 1, getBlob);
  func.call(*context, {
      jsa::Object::createFromHostObject(*context, std::make_shared<kraken::binding::JSBlob>(vector))
  });
}

TEST(JSCContext, getHostObject) {
  auto context = std::make_unique<JSCContext>(normalPrint);
  std::vector<uint8_t> vector = {1, 2, 3, 4, 5};
  jsa::HostFunctionType getBlob =
      [](jsa::JSContext &context, const jsa::Value &thisVal,
         const jsa::Value *args,
         size_t count) -> jsa::Value {
        auto &&object = args[0].getObject(context);
        EXPECT_EQ(object.isHostObject(context), true);
        std::shared_ptr<kraken::binding::JSBlob> blob = object.getHostObject<kraken::binding::JSBlob>(context);
        jsa::Value size = blob->get(context, jsa::PropNameID::forAscii(context, "size"));
        EXPECT_EQ(size.getNumber(), 5);

        return jsa::Value::undefined();
      };
  jsa::Function func = jsa::Function::createFromHostFunction(*context, jsa::PropNameID::forAscii(*context, "func"), 1, getBlob);
  func.call(*context, {
      jsa::Object::createFromHostObject(*context, std::make_shared<kraken::binding::JSBlob>(vector))
  });
}

TEST(JSCContext, codeSyntaxError) {
  auto errorPrint = [](const jsa::JSError &error) {
    EXPECT_STREQ(error.what(), "\nSyntaxError: Unexpected end of script\n"
                               "no stack");
  };
  auto context = std::make_unique<JSCContext>(errorPrint);
  jsa::Value result = context->evaluateJavaScript("qwe823-qe,sd.a.", "internal://", 0);
  EXPECT_EQ(result.isNull(), true);
}

TEST(JSCContext, undefinedError) {
  auto errorPrint = [](const jsa::JSError &error) {
    EXPECT_STREQ(error.what(), "\n"
                               "TypeError: null is not an object (evaluating 'obj.abc')\n"
                               "    at f (internal://:1:21)\n"
                               "    at global code (internal://:1:31)");
  };
  auto context = std::make_unique<JSCContext>(errorPrint);
  jsa::Value result = context->evaluateJavaScript("function f(obj) {obj.abc()}; f(null);", "internal://", 0);
  EXPECT_EQ(result.isNull(), true);
}

TEST(JSCContext, test) {
  auto errorPrint = [](const jsa::JSError &error) {
    EXPECT_STREQ(error.what(), "\n"
                               "ReferenceError: Can't find variable: setTimeout\n"
                               "    at global code (internal://:1:11)");
  };
  auto context = std::make_unique<JSCContext>(errorPrint);
  context->evaluateJavaScript("setTimeout('12345');", "internal://", 0);
}

#endif
