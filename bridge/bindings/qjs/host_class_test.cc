/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "host_class.h"
#include <unordered_map>
#include "bridge_qjs.h"
#include "gtest/gtest.h"

namespace kraken::binding::qjs {

class ParentClass : public HostClass {
 public:
  explicit ParentClass(JSContext* context) : HostClass(context, "ParentClass") {}
  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValueConst* argv) override {
    return HostClass::instanceConstructor(ctx, func_obj, this_val, argc, argv);
  }

  OBJECT_INSTANCE(ParentClass);

  static JSValue foo(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) { return JS_NewFloat64(ctx, 20); }

 private:
  ObjectFunction m_foo{m_context, m_prototypeObject, "foo", foo, 0};
};

class SampleClass;
static JSClassID kSampleClassId{0};

class SampleClassInstance : public Instance {
 public:
  explicit SampleClassInstance(HostClass* sampleClass) : Instance(sampleClass, "SampleClass", nullptr, kSampleClassId, finalizer){};

 private:
  static void finalizer(JSRuntime* rt, JSValue v) {
    auto* instance = static_cast<SampleClassInstance*>(JS_GetOpaque(v, kSampleClassId));
    if (instance->context()->isValid()) {
      JS_FreeValue(instance->m_ctx, instance->jsObject);
    }
    delete instance;
  }
};

std::once_flag kSampleClassOnceFlag;
class SampleClass : public ParentClass {
 public:
  explicit SampleClass(JSContext* context) : ParentClass(context) {
    std::call_once(kSampleClassOnceFlag, []() { JS_NewClassID(&kSampleClassId); });
    JS_SetPrototype(m_ctx, m_prototypeObject, ParentClass::instance(m_context)->prototype());
  }
  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override {
    auto* sampleClass = static_cast<SampleClass*>(JS_GetOpaque(func_obj, JSContext::kHostClassClassId));
    auto* instance = new SampleClassInstance(sampleClass);
    return instance->jsObject;
  }
  ~SampleClass() {}

 private:
  static JSValue f(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) { return JS_NewFloat64(ctx, 10); }

  ObjectFunction m_f{m_context, m_prototypeObject, "f", f, 0};
};

TEST(HostClass, newInstance) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "10");
  };
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  auto* sampleObject = new SampleClass(context.get());
  auto* parentObject = ParentClass::instance(context.get());
  context->defineGlobalProperty("SampleClass", sampleObject->jsObject);
  context->defineGlobalProperty("ParentClass", parentObject->jsObject);
  const char* code = "let obj = new SampleClass(1,2,3,4); console.log(obj.f())";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, instanceOf) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto& context = bridge->getContext();
  auto* sampleObject = new SampleClass(context.get());
  auto* parentObject = ParentClass::instance(context.get());
  // Test for C API
  context->defineGlobalProperty("SampleClass", sampleObject->jsObject);
  context->defineGlobalProperty("ParentClass", parentObject->jsObject);
  JSValue args[] = {};
  JSValue object = JS_CallConstructor(context->ctx(), sampleObject->jsObject, 0, args);
  bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, parentObject->jsObject);
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
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "20");
  };
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto& context = bridge->getContext();
  auto* sampleObject = new SampleClass(context.get());

  auto* parentObject = ParentClass::instance(context.get());
  context->defineGlobalProperty("ParentClass", parentObject->jsObject);

  context->defineGlobalProperty("SampleClass", sampleObject->jsObject);

  const char* code =
      "let obj = new SampleClass(1,2,3,4);\n"
      "console.log(obj.foo())";
  context->evaluateJavaScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, inherintanceInJavaScript) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "TEST 10 20");
  };
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto& context = bridge->getContext();
  auto* sampleObject = new SampleClass(context.get());

  auto* parentObject = ParentClass::instance(context.get());
  context->defineGlobalProperty("ParentClass", parentObject->jsObject);

  context->defineGlobalProperty("SampleClass", sampleObject->jsObject);

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
let demo = new Demo('test');
console.log(demo.getName(), demo.f(), demo.foo());
)";
  context->evaluateJavaScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, haveFunctionProtoMethods) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ƒ ()");
  };
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto& context = bridge->getContext();
  auto* parentObject = ParentClass::instance(context.get());
  context->defineGlobalProperty("ParentClass", parentObject->jsObject);

  const char* code = R"(
class Demo extends ParentClass {
  constructor(name) {
    super();
    this.name = name;
  }

  getName() {
    return this.name.toUpperCase();
  }
}
console.log(Demo.call);
)";
  context->evaluateJavaScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, multipleInstance) {
  bool static errorCalled = false;
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto& context = bridge->getContext();

  auto* parentObject = ParentClass::instance(context.get());
  context->defineGlobalProperty("ParentClass", parentObject->jsObject);

  // Test for C API 1
  {
    auto* sampleObject = new SampleClass(context.get());
    context->defineGlobalProperty("SampleClass1", sampleObject->jsObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->jsObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->jsObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  // Test for C API 2
  {
    auto* sampleObject = new SampleClass(context.get());
    context->defineGlobalProperty("SampleClass2", sampleObject->jsObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->jsObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->jsObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  {
    auto* sampleObject = new SampleClass(context.get());
    context->defineGlobalProperty("SampleClass3", sampleObject->jsObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->jsObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->jsObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  {
    auto* sampleObject = new SampleClass(context.get());
    context->defineGlobalProperty("SampleClass4", sampleObject->jsObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->jsObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->jsObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  delete bridge;
  EXPECT_EQ(errorCalled, false);
}

std::once_flag kExoticClassOnceFlag;

class ExoticClassInstance;
class ExoticClass : public HostClass {
 public:
  static JSClassID exoticClassID;
  ExoticClass() = delete;
  explicit ExoticClass(JSContext* context) : HostClass(context, "ExoticClass") {
    std::call_once(kExoticClassOnceFlag, []() { JS_NewClassID(&exoticClassID); });
  }
  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv);

 private:
  friend ExoticClassInstance;
};

JSClassID ExoticClass::exoticClassID{0};
static bool exoticClassFreed = false;

class ExoticClassInstance : public Instance {
 public:
  ExoticClassInstance() = delete;
  static JSClassExoticMethods methods;

  explicit ExoticClassInstance(ExoticClass* exoticClass) : Instance(exoticClass, "ExoticClass", &methods, ExoticClass::exoticClassID, finalizer){};

  static JSValue getProperty(QjsContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver) {
    auto* instance = static_cast<ExoticClassInstance*>(JS_GetOpaque(obj, ExoticClass::exoticClassID));
    auto* prototype = static_cast<ExoticClass*>(instance->prototype());
    if (JS_HasProperty(ctx, prototype->m_prototypeObject, atom)) {
      return JS_GetProperty(ctx, prototype->m_prototypeObject, atom);
    }

    if (instance->m_properties.count(atom) > 0) {
      return instance->m_properties[atom];
    }

    return JS_NULL;
  };

  static void finalizer(JSRuntime* rt, JSValue val) {
    auto* instance = static_cast<ExoticClassInstance*>(JS_GetOpaque(val, ExoticClass::exoticClassID));
    if (instance->context()->isValid()) {
      JS_FreeValue(instance->m_ctx, instance->jsObject);
    }
    delete instance;
  };

  static int setProperty(QjsContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags) {
    auto* instance = static_cast<ExoticClassInstance*>(JS_GetOpaque(obj, ExoticClass::exoticClassID));
    instance->m_properties[atom] = JS_DupValue(ctx, value);
    return 0;
  }
  ~ExoticClassInstance() { exoticClassFreed = true; }
  friend ExoticClass;

  class ClassNamePropertyDescriptor {
   public:
    static JSValue getter(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
      auto* instance = static_cast<ExoticClassInstance*>(JS_GetOpaque(this_val, ExoticClass::exoticClassID));
      return JS_NewFloat64(ctx, instance->classValue);
    };
    static JSValue setter(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
      auto* instance = static_cast<ExoticClassInstance*>(JS_GetOpaque(this_val, ExoticClass::exoticClassID));
      double v;
      JS_ToFloat64(ctx, &v, argv[0]);
      instance->classValue = v;
      return JS_NULL;
    };
  };
  ObjectProperty m_getClassName{m_context, jsObject, "className", ClassNamePropertyDescriptor::getter, ClassNamePropertyDescriptor::setter};

 private:
  std::unordered_map<JSAtom, JSValue> m_properties;
  double classValue{100.0};
};

JSClassExoticMethods ExoticClassInstance::methods{nullptr, nullptr, nullptr, nullptr, nullptr, getProperty, setProperty};

JSValue ExoticClass::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  return (new ExoticClassInstance(this))->jsObject;
}

TEST(HostClass, exoticClass) {
  bool static errorCalled = false;
  bool static logCalled = false;
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "10");
  };

  auto& context = bridge->getContext();
  auto* constructor = new ExoticClass(context.get());
  context->defineGlobalProperty("ExoticClass", constructor->jsObject);

  std::string code =
      "globalThis.obj = new ExoticClass();"
      "var key = 'onclick'; "
      "var otherKey = 'o' + 'n' + 'c' + 'l' + 'i' + 'c' + 'k';"
      "obj[key] = function() {return 10;};"
      "console.log(obj[otherKey]());";
  context->evaluateJavaScript(code.c_str(), code.size(), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(exoticClassFreed, true);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, setExoticClassProperty) {
  bool static errorCalled = false;
  bool static logCalled = false;
  auto* bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  kraken::JSBridge::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "200");
  };

  auto& context = bridge->getContext();
  auto* constructor = new ExoticClass(context.get());
  context->defineGlobalProperty("ExoticClass", constructor->jsObject);

  std::string code =
      "var obj = new ExoticClass();"
      "obj.className = 200.0;"
      "console.log(obj.className);";
  context->evaluateJavaScript(code.c_str(), code.size(), "vm://", 0);
  delete bridge;
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(exoticClassFreed, true);
  EXPECT_EQ(logCalled, true);
}

}  // namespace kraken::binding::qjs
