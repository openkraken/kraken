/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_H
#define KRAKENBRIDGE_JS_CONTEXT_H

#include "kraken_foundation.h"
#include <memory>
#include <quickjs/quickjs.h>

using QjsContext = JSContext;
using QjsRuntime = JSRuntime;

#define QJS_GLOBAL_BINDING_FUNCTION(context, function, name, argc)                                                     \
  {                                                                                                                    \
    JSValue f = JS_NewCFunction(context->context(), function, name, argc);                        \
    JS_DefinePropertyValue(context->context(), context->global(), JS_NewAtom(context->context(), name), f,                 \
                           JS_PROP_CONFIGURABLE | JS_PROP_ENUMERABLE);                                                 \
  }

namespace kraken::binding::qjs {

static JSClassID kHostObjectClassId{0};
static JSClassID kHostClassClassId{0};
static JSClassID kFunctionClassId{0};

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
  static QjsRuntime *runtime();
  int32_t getContextId();
  void *getOwner();
  bool handleException(JSValue *exc);
  void reportError(const char *errmsg);

  std::chrono::time_point<std::chrono::system_clock> timeOrigin;

  int32_t uniqueId;

private:
  int32_t contextId;
  JSExceptionHandler _handler;
  void *owner;
  std::atomic<bool> ctxInvalid_{false};
  QjsContext *m_ctx{nullptr};
};

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);
NativeString *jsValueToNativeString(QjsContext *ctx, JSValue &value);

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_JS_CONTEXT_H
