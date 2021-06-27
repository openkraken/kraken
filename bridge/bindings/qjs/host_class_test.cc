/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "host_class.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {

class SampleClass : public HostClass<SampleClass> {
public:
  explicit SampleClass(JSContext *context) : HostClass(context, "SampleClass") {}
private:
  static JSValue f(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    return JS_NewFloat64(ctx, 10);
  }

  HostClassFunction m_f{m_context, m_classObject, "f", f, 0};
};

TEST(HostClass, newInstance) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "10");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
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

}
