/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "host_object.h"
#include "js_context.h"
#include "bridge_qjs.h"
#include <gtest/gtest.h>

namespace kraken::binding::qjs {

static bool isSampleFree = false;

class SampleObject : public HostObject<SampleObject> {
public:
  explicit SampleObject(JSContext *context) : HostObject(context, "Screen"){};
  ~SampleObject() {
    isSampleFree = true;
  }
private:
  class FooPropertyDescriptor {
  public:
    static JSValue getter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
      auto *sampleObject = static_cast<SampleObject *>(JS_GetOpaque(this_val, kHostObjectClassId));
      return JS_NewFloat64(ctx, sampleObject->m_foo);
    }
    static JSValue setter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
      auto *sampleObject = static_cast<SampleObject *>(JS_GetOpaque(this_val, kHostObjectClassId));
      double f;
      JS_ToFloat64(ctx, &f, argv[0]);
      sampleObject->m_foo = f;
      return JS_NULL;
    }
  };

  static JSValue f(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    double v;
    JS_ToFloat64(ctx, &v, argv[0]);
    return JS_NewFloat64(ctx, 10 + v);
  }

  double m_foo{0};
  HostObjectProperty m_width{m_context, m_jsObject, "foo", FooPropertyDescriptor::getter, FooPropertyDescriptor::setter};
  HostObjectFunction m_f{m_context, m_jsObject, "f", f, 1};
};

TEST(HostObject, defineProperty) {
  bool static logCalled = false;
  bool static errorCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;

    EXPECT_STREQ(message.c_str(), "{f: ƒ (), foo: 1}");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    errorCalled = true;
  });
  auto &context = bridge->getContext();
  auto *sampleObject = new SampleObject(context.get());
  JSValue &object = sampleObject->m_jsObject;
  context->defineGlobalProperty("o", object);
  const char* code = "o.foo++; console.log(o);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(logCalled, true);
  EXPECT_EQ(errorCalled, false);
}

TEST(HostObject, defineFunction) {
  bool static logCalled = false;
  bool static errorCalled = false;
  kraken::JSBridge::consoleMessageHandler = [](void *ctx, const std::string &message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "20");
  };
  auto *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {
    KRAKEN_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto &context = bridge->getContext();
  auto *sampleObject = new SampleObject(context.get());
  JSValue &object = sampleObject->m_jsObject;
  context->defineGlobalProperty("o", object);
  const char* code = "console.log(o.f(10))";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  delete bridge;
  EXPECT_EQ(logCalled, true);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(isSampleFree, true);
}

} // namespace kraken::binding::qjs
