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
#include "bindings/qjs/module_manager.h"

namespace kraken::binding::qjs {

static std::atomic<int32_t> context_unique_id{0};

JSClassID JSContext::kHostClassClassId {0};
JSClassID JSContext::kHostObjectClassId {0};
JSClassID JSContext::kHostExoticObjectClassId{0};

#define MAX_JS_CONTEXT 1024
bool valid_contexts[MAX_JS_CONTEXT];
std::atomic<uint32_t> running_context_list{0};

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner) {
  return std::make_unique<JSContext>(contextId, handler, owner);
}

static JSRuntime *m_runtime{nullptr};

JSContext::JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner)
  : contextId(contextId), _handler(handler), owner(owner), ctxInvalid_(false), uniqueId(context_unique_id++) {
  // @FIXME: maybe contextId will larger than MAX_JS_CONTEXT
  valid_contexts[contextId] = true;
  if (contextId > running_context_list) running_context_list = contextId;

  std::call_once(kinitJSClassIDFlag, []() {
    JS_NewClassID(&kHostClassClassId);
    JS_NewClassID(&kHostObjectClassId);
    JS_NewClassID(&kHostExoticObjectClassId);
  });

  init_list_head(&node_job_list);
  init_list_head(&timer_job_list);
  init_list_head(&document_job_list);
  init_list_head(&module_job_list);
  init_list_head(&promise_job_list);
  init_list_head(&atom_job_list);
  init_list_head(&native_function_job_list);

  if (m_runtime == nullptr) {
    m_runtime = JS_NewRuntime();
  }
  // JavaScript and C are shared the same system call stack.
  JS_SetMaxStackSize(m_runtime, 5 * 1024 * 1024 /* 5MB stack */);
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
  valid_contexts[contextId] = false;
  JS_FreeValue(m_ctx, m_window->instanceObject);
  ctxInvalid_ = true;

  // Manual free nodes bound by each other.
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &node_job_list) {
      auto *node = list_entry(el, NodeJob, link);
      JS_FreeValue(m_ctx, node->nodeInstance->instanceObject);
    }
  }

  // Manual free nodes bound by document.
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &document_job_list) {
      auto *node = list_entry(el, NodeJob, link);
      JS_FreeValue(m_ctx, node->nodeInstance->instanceObject);
    }
  }
  // Manual free timers
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &timer_job_list) {
      auto *callbackContext = list_entry(el, TimerCallbackContext, link);
      JS_FreeValue(m_ctx, callbackContext->callback);
      delete callbackContext;
    }
  }

  // Manual free moduleListener
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &module_job_list) {
      auto *module = list_entry(el, ModuleContext, link);
      JS_FreeValue(m_ctx, module->callback);
      delete module;
    }
  }

  // Free unresolved promise.
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &promise_job_list) {
      auto *promiseContext = list_entry(el, PromiseContext, link);
      JS_FreeValue(m_ctx, promiseContext->resolveFunc);
      JS_FreeValue(m_ctx, promiseContext->rejectFunc);
      delete promiseContext;
    }
  }

  // Free unreleased atoms.
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &atom_job_list) {
      auto *job = list_entry(el, AtomJob, link);
      JS_FreeAtom(m_ctx, job->atom);
      delete job;
    }
  }

  // Free unreleased native_functions.
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &native_function_job_list) {
      auto *job = list_entry(el, NativeFunctionContext, link);
      delete job;
    }
  }

  // Free custom element constructor
  for (auto &e : Element::customElementConstructorMap) {
    JS_FreeValue(m_ctx, e.second);
  }
  Element::customElementConstructorMap.clear();

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
  drainPendingPromiseJobs();
  bool success = handleException(&result);
  JS_FreeValue(m_ctx, result);
  return success;
}

bool JSContext::evaluateJavaScript(const char16_t *code, size_t length, const char *sourceURL, int startLine) {
  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t *>(code), length));
  JSValue result = JS_Eval(m_ctx, utf8Code.c_str(), utf8Code.size(), sourceURL, JS_EVAL_TYPE_GLOBAL);
  drainPendingPromiseJobs();
  bool success = handleException(&result);
  JS_FreeValue(m_ctx, result);
  return success;
}

bool JSContext::evaluateJavaScript(const char *code, size_t codeLength, const char *sourceURL, int startLine) {
  JSValue result = JS_Eval(m_ctx, code, codeLength, sourceURL, JS_EVAL_TYPE_GLOBAL);
  drainPendingPromiseJobs();
  bool success = handleException(&result);
  JS_FreeValue(m_ctx, result);
  return success;
}

bool JSContext::evaluateByteCode(uint8_t *bytes, size_t byteLength) {
  JSValue obj, val;
  obj = JS_ReadObject(m_ctx, bytes, byteLength, JS_READ_OBJ_BYTECODE);
  if (!handleException(&obj)) return false;
  val = JS_EvalFunction(m_ctx, obj);
  if (!handleException(&val)) return false;
  JS_FreeValue(m_ctx, val);
  return true;
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
    dispatchGlobalErrorEvent(error);
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

void JSContext::reportError(JSValueConst error) {
  if (!JS_IsError(m_ctx, error)) return;

  const char *title = JS_ToCString(m_ctx, error);
  const char *stack = nullptr;
  JSValue stackValue = JS_GetPropertyStr(m_ctx, error, "stack");
  if (!JS_IsUndefined(stackValue)) {
    stack = JS_ToCString(m_ctx, stackValue);
  }

  uint32_t messageLength = strlen(title) + 2;
  if (stack != nullptr) {
    messageLength += strlen(stack);
    char message[messageLength];
    sprintf(message, "%s\n%s", title, stack);
    _handler(contextId, message);
  } else {
    char message[messageLength];
    sprintf(message, "%s", title);
    _handler(contextId, message);
  }

  JS_FreeValue(m_ctx, stackValue);
  JS_FreeCString(m_ctx, title);
  JS_FreeCString(m_ctx, stack);
}

void JSContext::drainPendingPromiseJobs() {
  // should executing pending promise jobs.
  QjsContext *pctx;
  int finished = JS_ExecutePendingJob(runtime(), &pctx);
  while (finished != 0) {
    finished = JS_ExecutePendingJob(runtime(), &pctx);
    if (finished == -1) {
      break;
    }
  }
}

void JSContext::defineGlobalProperty(const char *prop, JSValue value) {
  JSAtom atom = JS_NewAtom(m_ctx, prop);
  JS_SetProperty(m_ctx, globalObject, atom,  value);
  JS_FreeAtom(m_ctx, atom);
}

uint8_t *JSContext::dumpByteCode(const char *code, uint32_t codeLength, const char *sourceURL, size_t *bytecodeLength) {
  JSValue object = JS_Eval(m_ctx, code, codeLength, sourceURL, JS_EVAL_TYPE_GLOBAL | JS_EVAL_FLAG_COMPILE_ONLY);
  bool success = handleException(&object);
  if (!success) return nullptr;
  uint8_t *bytes = JS_WriteObject(m_ctx, bytecodeLength, object, JS_WRITE_OBJ_BYTECODE);
  JS_FreeValue(m_ctx, object);
  return bytes;
}

void JSContext::dispatchGlobalErrorEvent(JSValueConst error) {
  JSValue errorHandler = JS_GetPropertyStr(m_ctx, globalObject, "__global_onerror_handler__");
  JSValue returnValue = JS_Call(m_ctx, errorHandler, globalObject, 1, &error);
  if (JS_IsException(returnValue)) {
    JSValue error = JS_GetException(m_ctx);
    reportError(error);
    JS_FreeValue(m_ctx, error);
  }
  JS_FreeValue(m_ctx, returnValue);
  JS_FreeValue(m_ctx, errorHandler);
}

void JSContext::dispatchGlobalPromiseRejectionEvent(JSValueConst promise, JSValueConst error) {
  JSValue errorHandler = JS_GetPropertyStr(m_ctx, globalObject, "__global_unhandled_promise_handler__");
  JSValue arguments[] = {
    promise,
    error
  };
  JSValue returnValue = JS_Call(m_ctx, errorHandler, globalObject, 2, arguments);
  handleException(&returnValue);
  JS_FreeValue(m_ctx, returnValue);
  JS_FreeValue(m_ctx, errorHandler);
}

void JSContext::promiseRejectTracker(QjsContext *ctx, JSValue promise, JSValue reason, int is_handled, void *opaque) {
  auto *context = static_cast<JSContext *>(opaque);
  context->reportError(reason);
  context->dispatchGlobalPromiseRejectionEvent(promise, reason);
}

NativeString *jsValueToNativeString(QjsContext *ctx, JSValue value) {
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

NativeString *atomToNativeString(QjsContext *ctx, JSAtom atom) {
  JSValue stringValue = JS_AtomToString(ctx, atom);
  NativeString *string = jsValueToNativeString(ctx, stringValue);
  JS_FreeValue(ctx, stringValue);
  return string;
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

// An lock free context validator.
bool isContextValid(int32_t contextId) {
  if (contextId > running_context_list) return false;
  return valid_contexts[contextId];
}

} // namespace kraken::binding::qjs
