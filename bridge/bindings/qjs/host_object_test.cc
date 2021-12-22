/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "host_object.h"
#include <gtest/gtest.h>
#include "executing_context.h"
#include "kraken_test_env.h"
#include "page.h"

namespace kraken::binding::qjs {

static bool isSampleFree = false;

class SampleObject : public HostObject {
 public:
  explicit SampleObject(ExecutionContext* context) : HostObject(context, "SampleObject"){};
  ~SampleObject() { isSampleFree = true; }

 private:
  class FooPropertyDescriptor {
   public:
    static JSValue getter(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
      auto* sampleObject = static_cast<SampleObject*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
      return JS_NewFloat64(ctx, sampleObject->m_foo);
    }
    static JSValue setter(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
      auto* sampleObject = static_cast<SampleObject*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
      double f;
      JS_ToFloat64(ctx, &f, argv[0]);
      sampleObject->m_foo = f;
      return JS_NULL;
    }
  };

  static JSValue f(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
    double v;
    JS_ToFloat64(ctx, &v, argv[0]);
    return JS_NewFloat64(ctx, 10 + v);
  }

  double m_foo{0};
  ObjectProperty m_width{m_context, jsObject, "foo", FooPropertyDescriptor::getter, FooPropertyDescriptor::setter};
  ObjectFunction m_f{m_context, jsObject, "f", f, 1};
};

TEST(HostObject, defineProperty) {
  bool static logCalled = false;
  bool static errorCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;

    EXPECT_STREQ(message.c_str(), "{f: ƒ (), foo: 1}");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto& context = bridge->getContext();
  auto* sampleObject = new SampleObject(context.get());
  JSValue object = sampleObject->jsObject;
  context->defineGlobalProperty("o", object);
  const char* code = "o.foo++; console.log(o);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(logCalled, true);
  EXPECT_EQ(errorCalled, false);
}

TEST(ObjectProperty, worksWithProxy) {
  bool static logCalled = false;
  bool static errorCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "0");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  auto* sampleObject = new SampleObject(context.get());
  JSValue object = sampleObject->jsObject;
  context->defineGlobalProperty("o", object);
  std::string code = std::string(R"(
let p = new Proxy(o, {
    get(target, key, receiver) {
      return Reflect.get(target, key, receiver);
    }
});
console.log(p.foo);
)");
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(logCalled, true);
  EXPECT_EQ(errorCalled, false);
}

TEST(HostObject, defineFunction) {
  bool static logCalled = false;
  bool static errorCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "20");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  auto* sampleObject = new SampleObject(context.get());
  JSValue object = sampleObject->jsObject;
  context->defineGlobalProperty("o", object);
  const char* code = "console.log(o.f(10))";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(logCalled, true);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(isSampleFree, true);
}

class SampleExoticHostObject : public ExoticHostObject {
 public:
  explicit SampleExoticHostObject(ExecutionContext* context) : ExoticHostObject(context, "SampleObject"){};
  ~SampleExoticHostObject() { isSampleFree = true; }

  JSValue getProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver);
  int setProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags);

 private:
};

JSValue SampleExoticHostObject::getProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  return JS_NewFloat64(ctx, 100.0);
}
int SampleExoticHostObject::setProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  return 0;
}

TEST(ExoticHostObject, overriteGetterSetter) {
  bool static logCalled = false;
  bool static errorCalled = false;
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "100");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto& context = bridge->getContext();
  auto* sampleObject = new SampleExoticHostObject(context.get());
  JSValue object = sampleObject->jsObject;
  context->defineGlobalProperty("o", object);
  const char* code = "console.log(o.abc)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(logCalled, true);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(isSampleFree, true);
}

}  // namespace kraken::binding::qjs
