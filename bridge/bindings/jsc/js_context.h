/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_H
#define KRAKENBRIDGE_JS_CONTEXT_H

#include "foundation/js_engine_adaptor.h"
#include <JavaScriptCore/JavaScript.h>

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
  JSContext(int32_t contextId, const JSExceptionHandler& handler, void *owner);
  ~JSContext();

  void evaluateJavaScript(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine);
  void evaluateJavaScript(const char *code, const char *sourceURL, int startLine);

  bool isValid();

  int32_t getContextId();

  void *getOwner();

private:
  bool hasException(JSValueRef exc);
  bool hasException(JSValueRef res, JSValueRef exc);

  int32_t contextId;
  JSExceptionHandler _handler;
  void *owner;
  std::atomic<bool> ctxInvalid_;
  JSGlobalContextRef ctx_;
};

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_JS_CONTEXT_H
