/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_H
#define KRAKENBRIDGE_JS_CONTEXT_H

#include "kraken_foundation.h"
#include <forward_list>
#include <memory>
#include <quickjs/quickjs.h>

using QjsContext = JSContext;

#define QJS_GLOBAL_BINDING_FUNCTION(context, function, name, argc)                                                     \
  {                                                                                                                    \
    JSValue f = JS_NewCFunction(context->context(), function, name, argc);                                             \
    context->defineGlobalProperty(name, f);                                                                            \
  }

namespace kraken::binding::qjs {

static JSClassID kGlobalCustomClassId{0};

class JSContext {
public:
  JSContext() = delete;
  JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);
  ~JSContext();

  bool evaluateJavaScript(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine);
  bool evaluateJavaScript(const char16_t *code, size_t length, const char *sourceURL, int startLine);
  bool evaluateJavaScript(const char *code, size_t codeLength, const char *sourceURL, int startLine);
  bool isValid();
  JSValue global();
  QjsContext *context();
  JSRuntime *runtime();
  int32_t getContextId();
  void *getOwner();
  bool handleException(JSValue *exc);
  void reportError(JSValueConst &error);
  void defineGlobalProperty(const char *prop, JSValueConst value);

  std::chrono::time_point<std::chrono::system_clock> timeOrigin;

  int32_t uniqueId;

private:
  int32_t contextId;
  JSExceptionHandler _handler;
  void *owner;
  JSValue globalObject{JS_NULL};
  std::atomic<bool> ctxInvalid_{false};
  QjsContext *m_ctx{nullptr};
  std::forward_list<JSValue> m_globalProps;
};

class ObjectProperty {
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(ObjectProperty);

public:
  ObjectProperty() = delete;
  explicit ObjectProperty(JSContext *context, JSValueConst thisObject, const char *property,
                              JSCFunction getterFunction, JSCFunction setterFunction) {
    JSValue ge = JS_NewCFunction(context->context(), getterFunction, "get", 0);
    JSValue se = JS_NewCFunction(context->context(), setterFunction, "set", 1);
    JSAtom key = JS_NewAtom(context->context(), property);
    JS_DefinePropertyGetSet(context->context(), thisObject, key, ge, se,
                            JS_PROP_C_W_E);
    JS_FreeAtom(context->context(), key);
  };
};

class ObjectFunction {
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(ObjectFunction);

public:
  ObjectFunction() = delete;
  explicit ObjectFunction(JSContext *context, JSValueConst thisObject, const char *functionName,
                              JSCFunction function, int argc) {
    JSValue f = JS_NewCFunction(context->context(), function, functionName, argc);
    JSAtom key = JS_NewAtom(context->context(), functionName);

// We should avoid overwrite exist property functions.
#ifdef DEBUG
    assert_m(JS_HasProperty(context->context(), thisObject, key) == 0, (std::string("Found exist function property: ") + std::string(functionName)).c_str());
#endif

    JS_DefinePropertyValue(context->context(), thisObject, key, f,
                           JS_PROP_C_W_E);
    JS_FreeAtom(context->context(), key);
  };
};

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);
NativeString *jsValueToNativeString(QjsContext *ctx, JSValue &value);

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_JS_CONTEXT_H
