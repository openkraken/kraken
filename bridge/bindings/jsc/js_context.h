/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_H
#define KRAKENBRIDGE_JS_CONTEXT_H

#include "bindings/jsc/macros.h"
#include "include/kraken_bridge.h"
#include "foundation/js_engine_adaptor.h"
#include <JavaScriptCore/JavaScript.h>
#include <deque>
#include <map>
#include <string>
#include <chrono>

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

JSObjectRef propertyBindingFunction(JSContext *context, void *data, const char *name,
                                    JSObjectCallAsFunctionCallback callback);

NativeString **buildUICommandArgs(JSStringRef key);
NativeString **buildUICommandArgs(std::string &key);
NativeString **buildUICommandArgs(std::string &key, JSStringRef value);
NativeString **buildUICommandArgs(std::string &key, std::string &&value);
NativeString **buildUICommandArgs(std::string &&key, std::string &&value);
NativeString **buildUICommandArgs(std::string &key, JSContextRef ctx, JSValueRef value, JSValueRef *exception);

JSObjectRef JSObjectMakePromise(JSContext *context, void *data, JSObjectCallAsFunctionCallback callback, JSValueRef *exception);

std::string JSStringToStdString(JSStringRef jsString);

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_JS_CONTEXT_H
