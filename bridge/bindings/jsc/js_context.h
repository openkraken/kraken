/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_H
#define KRAKENBRIDGE_JS_CONTEXT_H

#include "bindings/jsc/macros.h"
#include "foundation/js_engine_adaptor.h"
#include "foundation/macros.h"
#include "include/kraken_bridge.h"
#include <JavaScriptCore/JavaScript.h>
#include <chrono>
#include <deque>
#include <map>
#include <string>

#ifndef __has_builtin
#define __has_builtin(x) 0
#endif

#if __has_builtin(__builtin_expect) || defined(__GNUC__)
#define JSC_LIKELY(EXPR) __builtin_expect((bool)(EXPR), true)
#define JSC_UNLIKELY(EXPR) __builtin_expect((bool)(EXPR), false)
#else
#define JSC_LIKELY(EXPR) (EXPR)
#define JSC_UNLIKELY(EXPR) (EXPR)
#endif

namespace kraken::binding::jsc {

class JSContext;

class JSFunctionHolder {
public:
  JSFunctionHolder() = delete;
  explicit JSFunctionHolder(JSContext *context, void *data, std::string name, JSObjectCallAsFunctionCallback callback);
  ~JSFunctionHolder();

  JSObjectRef function();

private:
  JSObjectRef m_function{nullptr};
  JSContext *context;
  void *m_data;
  std::string m_name;
  JSObjectCallAsFunctionCallback m_callback;
  FML_DISALLOW_COPY_ASSIGN_AND_MOVE(JSFunctionHolder);
};

class JSStringHolder {
public:
  JSStringHolder() = delete;
  explicit JSStringHolder(JSContext *context, const std::string &string);
  ~JSStringHolder();

  JSValueRef makeString();
  std::string string();

  const JSChar *ptr();
  size_t utf8Size();
  size_t size();
  bool empty();

  void setString(JSStringRef value);
  void setString(NativeString *value);

private:
  JSContext *m_context;
  JSStringRef m_string{nullptr};
  FML_DISALLOW_COPY_ASSIGN_AND_MOVE(JSStringHolder);
};

static inline bool isNumberIndex(std::string &name) {
  if (name.empty()) return false;
  char f = name[0];
  return f >= '0' && f <= '9';
}

class JSContext {
public:
  JSContext() = delete;
  JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);
  ~JSContext();

  bool evaluateJavaScript(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine);
  bool evaluateJavaScript(const char *code, const char *sourceURL, int startLine);

  bool isValid();

  JSObjectRef global();
  JSGlobalContextRef context();

  int32_t getContextId();

  void *getOwner();

  bool handleException(JSValueRef exc);

  void reportError(const char *errmsg);

  std::chrono::time_point<std::chrono::system_clock> timeOrigin;

private:
  int32_t contextId;
  JSExceptionHandler _handler;
  void *owner;
  std::atomic<bool> ctxInvalid_{false};
  JSGlobalContextRef ctx_;
};

JSObjectRef makeObjectFunctionWithPrivateData(JSContext *context, void *data, const char *name,
                                              JSObjectCallAsFunctionCallback callback);

NativeString **buildUICommandArgs(JSStringRef key);
NativeString **buildUICommandArgs(std::string &key);
NativeString **buildUICommandArgs(std::string &key, JSStringRef value);
NativeString **buildUICommandArgs(std::string &key, std::string &value);

JSObjectRef JSObjectMakePromise(JSContext *context, void *data, JSObjectCallAsFunctionCallback callback,
                                JSValueRef *exception);

std::string JSStringToStdString(JSStringRef jsString);

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_JS_CONTEXT_H
