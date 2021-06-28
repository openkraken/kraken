/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "host_class.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {

class ParentClass : public HostClass {
public:
  explicit ParentClass(JSContext *context) : HostClass(context, "ParentClass") {}
  JSValue constructor(QjsContext *ctx, JSValue this_val, int argc, JSValueConst *argv) override {
    return HostClass::constructor(ctx, this_val, argc, argv);
  }

  static JSValue foo(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    return JS_NewFloat64(ctx, 20);
  }
private:
  ObjectFunction m_foo{m_context, m_prototypeObject, "foo", foo, 0};
};

class SampleClass : public ParentClass {
public:
  explicit SampleClass(JSContext *context) : ParentClass(context) {}
  JSValue constructor(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) override {
    return ParentClass::constructor(ctx, this_val, argc, argv);
  }
private:
  static JSValue f(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    return JS_NewFloat64(ctx, 10);
  }

  ObjectFunction m_f{m_context, m_prototypeObject, "f", f, 0};
};

TEST(HostClass, newInstance) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "10");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto &context = bridge->getContext();
  auto *sampleObject = new SampleClass(context.get());
  context->defineGlobalProperty("SampleClass", sampleObject->m_classObject);
  const char* code = "let obj = new SampleClass(1,2,3,4); console.log(obj.f())";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, instanceOf) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto &context = bridge->getContext();
  auto *sampleObject = new SampleClass(context.get());
  // Test for C API
  context->defineGlobalProperty("SampleClass", sampleObject->m_classObject);
  JSValue args[] = {};
  JSValue object = JS_CallConstructor(context->context(), sampleObject->m_classObject, 0, args);
  bool isInstanceof = JS_IsInstanceOf(context->context(), object, sampleObject->m_classObject);
  EXPECT_EQ(isInstanceof, true);

  // Test with Javascript
  const char* code = "let obj = new SampleClass(1,2,3,4); \n console.log(obj instanceof SampleClass)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, inheritance) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "20");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto &context = bridge->getContext();
  auto *sampleObject = new SampleClass(context.get());

  context->defineGlobalProperty("SampleClass", sampleObject->m_classObject);

  const char* code = "let obj = new SampleClass(1,2,3,4);\n"
                     "console.log(obj.foo())";
  context->evaluateJavaScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

}
