/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_H
#define KRAKENBRIDGE_JS_CONTEXT_H

#include "kraken_foundation.h"
#include <memory>
#include <unordered_map>
#include <quickjs/quickjs.h>
#include <quickjs/list.h>
#include "js_context_macros.h"

using QjsContext = JSContext;

namespace kraken::binding::qjs {

static std::once_flag kinitJSClassIDFlag;

JSRuntime *getGlobalJSRuntime();
class WindowInstance;
class DocumentInstance;

class JSContext {
public:
  JSContext() = delete;
  JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);
  ~JSContext();

  bool evaluateJavaScript(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine);
  bool evaluateJavaScript(const char16_t *code, size_t length, const char *sourceURL, int startLine);
  bool evaluateJavaScript(const char *code, size_t codeLength, const char *sourceURL, int startLine);
  bool isValid() const;
  JSValue global();
  QjsContext *ctx();
  JSRuntime *runtime();
  int32_t getContextId() const;
  void *getOwner();
  bool handleException(JSValue *exc);
  void reportError(JSValueConst &error);
  void defineGlobalProperty(const char *prop, JSValueConst value);

  std::chrono::time_point<std::chrono::system_clock> timeOrigin;

  int32_t uniqueId;
  struct list_head node_list;
  struct list_head timer_list;
  struct list_head document_list;

  static JSClassID kHostClassClassId;
  static JSClassID kHostObjectClassId;

private:
  int32_t contextId;
  JSExceptionHandler _handler;
  void *owner;
  JSValue globalObject{JS_NULL};
  bool ctxInvalid_{false};
  QjsContext *m_ctx{nullptr};
  friend WindowInstance;
  friend DocumentInstance;
  WindowInstance *m_window{nullptr};
};

class ObjectProperty {
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(ObjectProperty);

public:
  ObjectProperty() = delete;
  explicit ObjectProperty(JSContext *context, JSValueConst thisObject, const char *property,
                              JSCFunction getterFunction, JSCFunction setterFunction) {
    JSValue ge = JS_NewCFunction(context->ctx(), getterFunction, "get", 0);
    JSValue se = JS_NewCFunction(context->ctx(), setterFunction, "set", 1);
    JSAtom key = JS_NewAtom(context->ctx(), property);
    JS_DefinePropertyGetSet(context->ctx(), thisObject, key, ge, se,
                            JS_PROP_C_W_E);
    JS_FreeAtom(context->ctx(), key);
  };
  explicit ObjectProperty(JSContext *context, JSValueConst thisObject, const char *property,
                          JSCFunction getterFunction) {
    JSValue get = JS_NewCFunction(context->ctx(), getterFunction, "get", 0);
    JSAtom key = JS_NewAtom(context->ctx(), property);
    JS_DefineProperty(context->ctx(), thisObject, key, JS_UNDEFINED, get, JS_UNDEFINED,
                            JS_PROP_HAS_CONFIGURABLE | JS_PROP_ENUMERABLE | JS_PROP_HAS_GET);
    JS_FreeAtom(context->ctx(), key);
  }
};

class ObjectFunction {
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(ObjectFunction);

public:
  ObjectFunction() = delete;
  explicit ObjectFunction(JSContext *context, JSValueConst thisObject, const char *functionName,
                              JSCFunction function, int argc) {
    JSValue f = JS_NewCFunction(context->ctx(), function, functionName, argc);
    JSAtom key = JS_NewAtom(context->ctx(), functionName);

// We should avoid overwrite exist property functions.
#ifdef DEBUG
    assert_m(JS_HasProperty(context->ctx(), thisObject, key) == 0, (std::string("Found exist function property: ") + std::string(functionName)).c_str());
#endif

    JS_DefinePropertyValue(context->ctx(), thisObject, key, f,
                           JS_PROP_ENUMERABLE);
    JS_FreeAtom(context->ctx(), key);
  };
};

class JSValueHolder {
public:
  JSValueHolder() = delete;
  explicit JSValueHolder(JSContext *context, JSValue value): m_value(value), m_context(context) {};
  ~JSValueHolder() {
    if (m_context->isValid()) {
      JS_FreeValue(m_context->ctx(), m_value);
    }
  }
  inline void setValue(JSValue value) {
    m_value = value;
  };
  inline JSValue value() const { return m_value; }
private:
  JSContext *m_context{nullptr};
  JSValue m_value{JS_NULL};
};

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);
NativeString *jsValueToNativeString(QjsContext *ctx, JSValue &value);
void buildUICommandArgs(QjsContext *ctx, JSValue key, NativeString &args_01);
NativeString *stringToNativeString(std::string &string);
std::string jsValueToStdString(QjsContext *ctx, JSValue &value);
std::string jsAtomToStdString(QjsContext *ctx, JSAtom atom);


} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_JS_CONTEXT_H
