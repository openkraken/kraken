/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "host_class.h"
#include <unordered_map>
#include "gtest/gtest.h"
#include "kraken_test_env.h"
#include "page.h"

namespace kraken::binding::qjs {

class ParentClass : public HostClass {
 public:
  explicit ParentClass(ExecutionContext* context) : HostClass(context, "ParentClass") {}
  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValueConst* argv) override { return HostClass::instanceConstructor(ctx, func_obj, this_val, argc, argv); }

  OBJECT_INSTANCE(ParentClass);

  static JSValue foo(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) { return JS_NewFloat64(ctx, 20); }

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
  explicit SampleClass(ExecutionContext* context) : ParentClass(context) {
    std::call_once(kSampleClassOnceFlag, []() { JS_NewClassID(&kSampleClassId); });
    JS_SetPrototype(m_ctx, m_prototypeObject, ParentClass::instance(m_context)->prototype());
  }
  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override {
    auto* sampleClass = static_cast<SampleClass*>(JS_GetOpaque(func_obj, ExecutionContext::kHostClassClassId));
    auto* instance = new SampleClassInstance(sampleClass);
    return instance->jsObject;
  }
  ~SampleClass() {}

 private:
  static JSValue f(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) { return JS_NewFloat64(ctx, 10); }

  ObjectFunction m_f{m_context, m_prototypeObject, "f", f, 0};
};

TEST(HostClass, newInstance) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "10");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->getContext();
  auto* sampleObject = new SampleClass(context);
  auto* parentObject = ParentClass::instance(context);
  context->defineGlobalProperty("SampleClass", sampleObject->jsObject);
  context->defineGlobalProperty("ParentClass", parentObject->jsObject);
  const char* code = "let obj = new SampleClass(1,2,3,4); console.log(obj.f())";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, instanceOf) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto context = bridge->getContext();
  auto* sampleObject = new SampleClass(context);
  auto* parentObject = ParentClass::instance(context);
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

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, inheritance) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "20");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto context = bridge->getContext();
  auto* sampleObject = new SampleClass(context);

  auto* parentObject = ParentClass::instance(context);
  context->defineGlobalProperty("ParentClass", parentObject->jsObject);

  context->defineGlobalProperty("SampleClass", sampleObject->jsObject);

  const char* code =
      "let obj = new SampleClass(1,2,3,4);\n"
      "console.log(obj.foo())";
  context->evaluateJavaScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, inherintanceInJavaScript) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "TEST 10 20");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto context = bridge->getContext();
  auto* sampleObject = new SampleClass(context);

  auto* parentObject = ParentClass::instance(context);
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

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, haveFunctionProtoMethods) {
  bool static errorCalled = false;
  bool static logCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ƒ ()");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto context = bridge->getContext();
  auto* parentObject = ParentClass::instance(context);
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

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, multipleInstance) {
  bool static errorCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    errorCalled = true;
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  auto context = bridge->getContext();

  auto* parentObject = ParentClass::instance(context);
  context->defineGlobalProperty("ParentClass", parentObject->jsObject);

  // Test for C API 1
  {
    auto* sampleObject = new SampleClass(context);
    context->defineGlobalProperty("SampleClass1", sampleObject->jsObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->jsObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->jsObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  // Test for C API 2
  {
    auto* sampleObject = new SampleClass(context);
    context->defineGlobalProperty("SampleClass2", sampleObject->jsObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->jsObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->jsObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  {
    auto* sampleObject = new SampleClass(context);
    context->defineGlobalProperty("SampleClass3", sampleObject->jsObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->jsObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->jsObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  {
    auto* sampleObject = new SampleClass(context);
    context->defineGlobalProperty("SampleClass4", sampleObject->jsObject);
    JSValue args[] = {};
    JSValue object = JS_CallConstructor(context->ctx(), sampleObject->jsObject, 0, args);
    bool isInstanceof = JS_IsInstanceOf(context->ctx(), object, sampleObject->jsObject);
    EXPECT_EQ(isInstanceof, true);
    JS_FreeValue(context->ctx(), object);
  }

  EXPECT_EQ(errorCalled, false);
}

std::once_flag kExoticClassOnceFlag;

class ExoticClassInstance;
class ExoticClass : public HostClass {
 public:
  static JSClassID exoticClassID;
  ExoticClass() = delete;
  explicit ExoticClass(ExecutionContext* context) : HostClass(context, "ExoticClass") {
    std::call_once(kExoticClassOnceFlag, []() { JS_NewClassID(&exoticClassID); });
  }
  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv);

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

  static JSValue getProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver) {
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

  static int setProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags) {
    auto* instance = static_cast<ExoticClassInstance*>(JS_GetOpaque(obj, ExoticClass::exoticClassID));
    instance->m_properties[atom] = JS_DupValue(ctx, value);
    return 0;
  }
  ~ExoticClassInstance() { exoticClassFreed = true; }
  friend ExoticClass;

  class ClassNamePropertyDescriptor {
   public:
    static JSValue getter(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
      auto* instance = static_cast<ExoticClassInstance*>(JS_GetOpaque(this_val, ExoticClass::exoticClassID));
      return JS_NewFloat64(ctx, instance->classValue);
    };
    static JSValue setter(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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

JSValue ExoticClass::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  return (new ExoticClassInstance(this))->jsObject;
}

TEST(HostClass, exoticClass) {
  bool static errorCalled = false;
  bool static logCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "10");
  };

  auto context = bridge->getContext();
  auto* constructor = new ExoticClass(context);
  context->defineGlobalProperty("ExoticClass", constructor->jsObject);

  std::string code =
      "globalThis.obj = new ExoticClass();"
      "var key = 'onclick'; "
      "var otherKey = 'o' + 'n' + 'c' + 'l' + 'i' + 'c' + 'k';"
      "obj[key] = function() {return 10;};"
      "console.log(obj[otherKey]());";
  context->evaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, setExoticClassProperty) {
  bool static errorCalled = false;
  bool static logCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "200");
  };

  auto context = bridge->getContext();
  auto* constructor = new ExoticClass(context);
  context->defineGlobalProperty("ExoticClass", constructor->jsObject);

  std::string code =
      "var obj = new ExoticClass();"
      "obj.className = 200.0;"
      "console.log(obj.className);";
  context->evaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(exoticClassFreed, true);
  EXPECT_EQ(logCalled, true);
}

TEST(HostClass, finalizeShouldNotFree) {
  bool static errorCalled = false;
  bool static logCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };

  auto context = bridge->getContext();
  auto* constructor = new ExoticClass(context);
  context->defineGlobalProperty("ExoticClass", constructor->jsObject);

  auto runGC = [](JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) -> JSValue {
    JS_RunGC(JS_GetRuntime(ctx));
    return JS_NULL;
  };
  QJS_GLOBAL_BINDING_FUNCTION(context, runGC, "__kraken_run_gc__", 1);

  std::string code = R"(
function throttle(func, wait) {
  var ctx;
  var args;
  var rtn;
  var timeoutID;
  var last = 0;

  function call() {
    timeoutID = 0;
    last = +new Date();
    rtn = func.apply(ctx, args);
    ctx = null;
    // args = null;
  }

  return function () {
    ctx = this;
    args = arguments;
    var delta = new Date().getTime() - last;
    if (!timeoutID) if (delta >= wait) call();else timeoutID = setTimeout(call, wait - delta);
    return rtn;
  };
}

var handleScroll = function (e) {
};

{
  let div;
  function initScroll() {
    div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '300px';
    div.style.overflow = 'scroll';
    div.addEventListener('scroll', throttle(handleScroll, 100));
    document.body.appendChild(div);
    for(let i = 0; i < 1000; i ++) {
      div.appendChild(document.createTextNode('abc'));
    }
  }

  function triggerScroll() {
    let scrollEvent = new CustomEvent('scroll');
    div.dispatchEvent(scrollEvent);
  }

  initScroll();
  window.onclick = () => {
    document.body.removeChild(div)
    initScroll();
  };
  window.addEventListener('trigger', () => {
    triggerScroll();
  });
}

)";
  context->evaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  static auto* window = static_cast<EventTargetInstance*>(JS_GetOpaque(context->global(), 1));

  auto triggerScrollEventAndLoopTimer = [&context]() {
    TEST_dispatchEvent(context->getContextId(), window, "trigger");
    TEST_runLoop(context);
  };

  triggerScrollEventAndLoopTimer();
  triggerScrollEventAndLoopTimer();
  triggerScrollEventAndLoopTimer();

  TEST_dispatchEvent(context->getContextId(), window, "click");

  triggerScrollEventAndLoopTimer();
  triggerScrollEventAndLoopTimer();
  triggerScrollEventAndLoopTimer();

  TEST_dispatchEvent(context->getContextId(), window, "click");

  triggerScrollEventAndLoopTimer();
  triggerScrollEventAndLoopTimer();
}

}  // namespace kraken::binding::qjs
