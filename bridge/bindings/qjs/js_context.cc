/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "js_context.h"
#include "kraken_bridge.h"
#include "qjs_patch.h"

namespace kraken::binding::qjs {

static std::atomic<int32_t> context_unique_id{0};
std::once_flag kGlobalClassIdFlag;

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner) {
  return std::make_unique<JSContext>(contextId, handler, owner);
}

NativeString *jsValueToNativeString(QjsContext *ctx, JSValue &value) {
  if (!JS_IsString(value)) {
    return nullptr;
  }

  uint32_t length;
  uint16_t *buffer = JS_ToUnicode(ctx, value, &length);
  NativeString tmp{};
  tmp.string = buffer;
  tmp.length = length;
  return tmp.clone();
}

void promiseRejectTracker(QjsContext *ctx, JSValueConst promise,
                          JSValueConst reason,
                          JS_BOOL is_handled, void *opaque) {
  auto *context = static_cast<JSContext *>(opaque);
  context->reportError(reason);
}

JSContext::JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner)
  : contextId(contextId), _handler(handler), owner(owner), ctxInvalid_(false), uniqueId(context_unique_id++) {

  std::call_once(kGlobalClassIdFlag, []() {
    JS_NewClassID(&kHostObjectClassId);
    JS_NewClassID(&kHostClassClassId);
    JS_NewClassID(&kFunctionClassId);
  });

  m_runtime = JS_NewRuntime();
  m_ctx = JS_NewContext(m_runtime);

  timeOrigin = std::chrono::system_clock::now();
  globalObject = JS_GetGlobalObject(m_ctx);

  JS_SetContextOpaque(m_ctx, this);
  JS_SetHostPromiseRejectionTracker(m_runtime, promiseRejectTracker, this);
}

JSContext::~JSContext() {
  ctxInvalid_ = true;

  for (auto &prop : m_globalProps) {
    JS_FreeValue(m_ctx, prop);
  }

  JS_FreeValue(m_ctx, globalObject);
  JS_FreeContext(m_ctx);
  JS_FreeRuntime(m_runtime);
  m_ctx = nullptr;
}

bool JSContext::evaluateJavaScript(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine) {
  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t *>(code), codeLength));
  JSValue result = JS_Eval(m_ctx, utf8Code.c_str(), utf8Code.size(), sourceURL, JS_EVAL_TYPE_GLOBAL);
  bool hasException = handleException(&result);
  JS_FreeValue(m_ctx, result);
  return hasException;
}

bool JSContext::evaluateJavaScript(const char16_t *code, size_t length, const char *sourceURL, int startLine) {
  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t *>(code), length));
  JSValue result = JS_Eval(m_ctx, utf8Code.c_str(), utf8Code.size(), sourceURL, JS_EVAL_TYPE_GLOBAL);
  bool hasException = handleException(&result);
  JS_FreeValue(m_ctx, result);
  return hasException;
}

bool JSContext::evaluateJavaScript(const char *code, size_t codeLength, const char *sourceURL, int startLine) {
  JSValue result = JS_Eval(m_ctx, code, codeLength, sourceURL, JS_EVAL_TYPE_GLOBAL);
  bool hasException = handleException(&result);
  JS_FreeValue(m_ctx, result);
  return hasException;
}

bool JSContext::isValid() {
  return !ctxInvalid_;
}

int32_t JSContext::getContextId() {
  assert(!ctxInvalid_ && "context has been released");
  return contextId;
}

void *JSContext::getOwner() {
  assert(!ctxInvalid_ && "context has been released");
  return owner;
}

bool JSContext::handleException(JSValue *exception) {
  if (JS_IsException(*exception)) {
    JSValue error = JS_GetException(m_ctx);
    reportError(error);
    JS_FreeValue(m_ctx, error);
    return false;
  }

  return true;
}

JSValue JSContext::global() {
  return JS_GetGlobalObject(m_ctx);
}

QjsContext *JSContext::context() {
  assert(!ctxInvalid_ && "context has been released");
  return m_ctx;
}

QjsRuntime *JSContext::runtime() {
  return m_runtime;
}

void JSContext::reportError(JSValueConst &error) {
  if (!JS_IsError(m_ctx, error)) return;

  const char *title = JS_ToCString(m_ctx, error);
  const char *stack = nullptr;
  JSValue stackValue = JS_GetPropertyStr(m_ctx, error, "stack");
  if (!JS_IsUndefined(stackValue)) {
    stack = JS_ToCString(m_ctx, stackValue);
    JS_FreeCString(m_ctx, stack);
  }
  JS_FreeCString(m_ctx, title);
  JS_FreeValue(m_ctx, stackValue);

  _handler(contextId, (std::string(title) + "\n" + std::string(stack)).c_str());
}

void JSContext::defineGlobalProperty(const char* prop, JSValue value) {
  JSAtom atom = JS_NewAtom(m_ctx, prop);
  JS_DefineProperty(m_ctx, globalObject, atom, value,
                    JS_UNDEFINED, JS_UNDEFINED, JS_PROP_HAS_VALUE);
  m_globalProps.emplace_front(value);
  JS_FreeAtom(m_ctx, atom);
}

} // namespace kraken::binding::qjs
