/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "js_context.h"
#include "kraken_bridge.h"
#include "qjs_patch.h"
#include "bindings/qjs/bom/window.h"
#include "bindings/qjs/dom/document.h"
#include "bindings/qjs/bom/timer.h"

namespace kraken::binding::qjs {

static std::atomic<int32_t> context_unique_id{0};

JSClassID JSContext::kHostClassClassId {0};
JSClassID JSContext::kHostObjectClassId {0};

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner) {
  return std::make_unique<JSContext>(contextId, handler, owner);
}

void promiseRejectTracker(QjsContext *ctx, JSValueConst promise, JSValueConst reason, JS_BOOL is_handled,
                          void *opaque) {
  auto *context = static_cast<JSContext *>(opaque);
  context->reportError(reason);
}

static JSRuntime *m_runtime{nullptr};

JSContext::JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner)
  : contextId(contextId), _handler(handler), owner(owner), ctxInvalid_(false), uniqueId(context_unique_id++) {

  std::call_once(kinitJSClassIDFlag, []() {
    JS_NewClassID(&kHostClassClassId);
    JS_NewClassID(&kHostObjectClassId);
  });

  init_list_head(&node_list);
  init_list_head(&timer_list);

  if (m_runtime == nullptr) {
    m_runtime = JS_NewRuntime();
  }
  // JavaScript and C are shared the same system call stack.
  JS_SetMaxStackSize(m_runtime, 10 * 1024 * 1024 /* 10MB stack */);
  m_ctx = JS_NewContext(m_runtime);

  timeOrigin = std::chrono::system_clock::now();
  globalObject = JS_GetGlobalObject(m_ctx);
  JSValue windowGetter = JS_NewCFunction(
    m_ctx,
    [](QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) -> JSValue {
      return JS_GetGlobalObject(ctx);
    },
    "get", 0);
  JSAtom windowKey = JS_NewAtom(m_ctx, "window");
  JS_DefinePropertyGetSet(m_ctx, globalObject, windowKey, windowGetter, JS_UNDEFINED,
                          JS_PROP_HAS_GET | JS_PROP_ENUMERABLE);
  JS_FreeAtom(m_ctx, windowKey);
  JS_SetContextOpaque(m_ctx, this);
  JS_SetHostPromiseRejectionTracker(m_runtime, promiseRejectTracker, this);
}

JSContext::~JSContext() {
  JS_FreeValue(m_ctx, m_window->instanceObject);
  ctxInvalid_ = true;

  // Manual free nodes
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &node_list) {
      auto *node = list_entry(el, NodeLink, link);
      JS_FreeValue(m_ctx, node->nodeInstance->instanceObject);
    }
  }
  // Manual free timers
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &timer_list) {
      auto *callbackContext = list_entry(el, TimerCallbackContext, link);
      JS_FreeValue(m_ctx, callbackContext->callback);
    }
  }

  JS_RunGC(m_runtime);
  JS_FreeValue(m_ctx, globalObject);
  JS_FreeContext(m_ctx);
  JS_RunGC(m_runtime);

#if DUMP_LEAKS
  JS_FreeRuntime(m_runtime);
  m_runtime = nullptr;
#endif
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

bool JSContext::isValid() const {
  return !ctxInvalid_;
}

int32_t JSContext::getContextId() const {
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
  return globalObject;
}

QjsContext *JSContext::ctx() {
  assert(!ctxInvalid_ && "context has been released");
  return m_ctx;
}

JSRuntime *JSContext::runtime() {
  return m_runtime;
}

void JSContext::reportError(JSValueConst &error) {
  if (!JS_IsError(m_ctx, error)) return;

  const char *title = JS_ToCString(m_ctx, error);
  const char *stack = nullptr;
  JSValue stackValue = JS_GetPropertyStr(m_ctx, error, "stack");
  if (!JS_IsUndefined(stackValue)) {
    stack = JS_ToCString(m_ctx, stackValue);
  }

  _handler(contextId, (std::string(title) + "\n" + std::string(stack)).c_str());

  JS_FreeValue(m_ctx, stackValue);
  JS_FreeCString(m_ctx, title);
  JS_FreeCString(m_ctx, stack);
}

void JSContext::defineGlobalProperty(const char *prop, JSValue value) {
  JSAtom atom = JS_NewAtom(m_ctx, prop);
  JS_SetProperty(m_ctx, globalObject, atom,  value);
  JS_FreeAtom(m_ctx, atom);
}

NativeString *jsValueToNativeString(QjsContext *ctx, JSValue &value) {
  bool isValueString = true;
  if (!JS_IsString(value)) {
    value = JS_ToString(ctx, value);
    isValueString = false;
  }

  uint32_t length;
  uint16_t *buffer = JS_ToUnicode(ctx, value, &length);
  NativeString tmp{};
  tmp.string = buffer;
  tmp.length = length;
  NativeString *cloneString = tmp.clone();

  if (!isValueString) {
    JS_FreeValue(ctx, value);
  }
  return cloneString;
}

void buildUICommandArgs(QjsContext *ctx, JSValue key, NativeString &args_01) {
  if (!JS_IsString(key)) return;

  uint32_t length;
  uint16_t *buffer = JS_ToUnicode(ctx, key, &length);
  args_01.string = buffer;
  args_01.length = length;
}

NativeString *stringToNativeString(std::string &string) {
  std::u16string utf16;
  fromUTF8(string, utf16);
  NativeString tmp{};
  tmp.string = reinterpret_cast<const uint16_t *>(utf16.c_str());
  tmp.length = utf16.size();
  return tmp.clone();
}

JSRuntime *getGlobalJSRuntime() {
  return m_runtime;
}

std::string jsValueToStdString(QjsContext *ctx, JSValue &value) {
  const char* cString = JS_ToCString(ctx, value);
  std::string str = std::string(cString);
  JS_FreeCString(ctx, cString);
  return str;
}

std::string jsAtomToStdString(QjsContext *ctx, JSAtom atom) {
  const char* cstr = JS_AtomToCString(ctx, atom);
  std::string str = std::string(cstr);
  JS_FreeCString(ctx, cstr);
  return str;
}

} // namespace kraken::binding::qjs
