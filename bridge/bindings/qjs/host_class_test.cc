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
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValueConst *argv) override {
    return HostClass::constructor(ctx, func_obj, this_val, argc, argv);
  }

  static JSValue foo(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    return JS_NewFloat64(ctx, 20);
  }
private:
  ObjectFunction m_foo{m_context, m_prototypeObject, "foo", foo, 0};
};

class SampleClass;

class SampleClassInstance : public Instance {
public:
  explicit SampleClassInstance(HostClass *sampleClass) : Instance(sampleClass, "SampleClass") {};
private:
};

class SampleClass : public ParentClass {
public:
  explicit SampleClass(JSContext *context) : ParentClass(context) {}
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override {
    auto *sampleClass = static_cast<SampleClass *>(JS_GetOpaque(func_obj, JSContext::kHostClassClassId));
    auto *instance = new SampleClassInstance(sampleClass);
    return instance->instanceObject;
  }
  ~SampleClass() {}
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
  context->defineGlobalProperty("SampleClass", sampleObject->classObject);
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
  context->defineGlobalProperty("SampleClass", sampleObject->classObject);
  JSValue args[] = {};
  JSValue object = JS_CallConstructor(context->ctx(), sampleObject->classObject, 0, args);
  bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->classObject);
  EXPECT_EQ(isInstanceof, true);
  JS_FreeValue(context->ctx(), object);

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

  context->defineGlobalProperty("SampleClass", sampleObject->classObject);

  const char* code = "let obj = new SampleClass(1,2,3,4);\n"
                     "console.log(obj.foo())";
  context->evaluateJavaScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, inherintanceInJavaScript) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ANDYCALL 10 20");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto &context = bridge->getContext();
  auto *sampleObject = new SampleClass(context.get());

  context->defineGlobalProperty("SampleClass", sampleObject->classObject);

  const char* code = R"(
class Demo extends SampleClass {
  constructor(name) {
    super();
    this.name = name;
  }

  getName() {
    return this.name.toUpperCase();
  }
}
let demo = new Demo('andycall');
console.log(demo.getName(), demo.f(), demo.foo());
)";
  context->evaluateJavaScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, multipleInstance) {
  bool static errorCalled = false;
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto &context = bridge->getContext();

  // Test for C API 1
  {
    auto *sampleObject = new SampleClass(context.get());
    context->defineGlobalProperty("SampleClass1", sampleObject->classObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->classObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->classObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  // Test for C API 2
  {
    auto *sampleObject = new SampleClass(context.get());
    context->defineGlobalProperty("SampleClass2", sampleObject->classObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->classObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->classObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  {
    auto *sampleObject = new SampleClass(context.get());
    context->defineGlobalProperty("SampleClass3", sampleObject->classObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->classObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->classObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  {
    auto *sampleObject = new SampleClass(context.get());
    context->defineGlobalProperty("SampleClass4", sampleObject->classObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->classObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->classObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  delete bridge;
  EXPECT_EQ(errorCalled, false);
}


class ExoticClass : public HostClass {
public:
  ExoticClass() = delete;
  explicit ExoticClass(JSContext *context) : HostClass(context, "ExoticClass") {}
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv);
private:

};

class ExoticClassInstance : public Instance {
public:
  ExoticClassInstance() = delete;
  JSClassExoticMethods methods{
    nullptr,
    nullptr,
    nullptr,
    nullptr,
    nullptr,
    nullptr,
    setProperty
  };

  explicit ExoticClassInstance(ExoticClass *exoticClass) : Instance(exoticClass, "ExoticClass", methods) {};

  static int setProperty(QjsContext *ctx, JSValueConst obj, JSAtom atom,
                         JSValueConst value, JSValueConst receiver, int flags) {
    KRAKEN_LOG(VERBOSE) << JS_AtomToCString(ctx, atom);
    return 0;
  }
  ~ExoticClassInstance() {
    KRAKEN_LOG(VERBOSE) << "delete";
  }
};

JSValue ExoticClass::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return (new ExoticClassInstance(this))->instanceObject;
}

TEST(HostClass, exoticClass) {
  bool static errorCalled = false;
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });

  auto &context = bridge->getContext();
  auto *constructor = new ExoticClass(context.get());
  context->defineGlobalProperty("ExoticClass", constructor->classObject);

  std::string code = "globalThis.obj = new ExoticClass();";
  context->evaluateJavaScript(code.c_str(), code.size(), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
}

}
