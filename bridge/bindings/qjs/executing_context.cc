/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "executing_context.h"
#include "bindings/qjs/bom/timer.h"
#include "bindings/qjs/bom/window.h"
#include "bindings/qjs/dom/document.h"
#include "bindings/qjs/module_manager.h"
#include "bom/dom_timer_coordinator.h"
#include "garbage_collected.h"
#include "kraken_bridge.h"
#include "qjs_patch.h"

namespace kraken::binding::qjs {

static std::atomic<int32_t> context_unique_id{0};

JSClassID ExecutionContext::kHostClassClassId{0};
JSClassID ExecutionContext::kHostObjectClassId{0};
JSClassID ExecutionContext::kHostExoticObjectClassId{0};

std::atomic<int32_t> runningContexts{0};

#define MAX_JS_CONTEXT 1024
bool valid_contexts[MAX_JS_CONTEXT];
std::atomic<uint32_t> running_context_list{0};

std::unique_ptr<ExecutionContext> createJSContext(int32_t contextId, const JSExceptionHandler& handler, void* owner) {
  return std::make_unique<ExecutionContext>(contextId, handler, owner);
}

static JSRuntime* m_runtime{nullptr};

void ExecutionContextGCTracker::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(m_ctx));
  context->trace(rt, context->global(), mark_func);
}
void ExecutionContextGCTracker::dispose() const {}

JSClassID ExecutionContextGCTracker::contextGcTrackerClassId{0};

ExecutionContext::ExecutionContext(int32_t contextId, const JSExceptionHandler& handler, void* owner)
    : contextId(contextId), _handler(handler), owner(owner), ctxInvalid_(false), uniqueId(context_unique_id++) {
  // @FIXME: maybe contextId will larger than MAX_JS_CONTEXT
  valid_contexts[contextId] = true;
  if (contextId > running_context_list)
    running_context_list = contextId;

  std::call_once(kinitJSClassIDFlag, []() {
    JS_NewClassID(&kHostClassClassId);
    JS_NewClassID(&kHostObjectClassId);
    JS_NewClassID(&kHostExoticObjectClassId);
  });

  init_list_head(&node_job_list);
  init_list_head(&module_job_list);
  init_list_head(&module_callback_job_list);
  init_list_head(&promise_job_list);
  init_list_head(&native_function_job_list);

  if (m_runtime == nullptr) {
    m_runtime = JS_NewRuntime();
  }
  m_ctx = JS_NewContext(m_runtime);

  timeOrigin = std::chrono::system_clock::now();
  globalObject = JS_GetGlobalObject(m_ctx);
  JSValue windowGetter = JS_NewCFunction(
      m_ctx, [](JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) -> JSValue { return JS_GetGlobalObject(ctx); }, "get", 0);
  JSAtom windowKey = JS_NewAtom(m_ctx, "window");
  JS_DefinePropertyGetSet(m_ctx, globalObject, windowKey, windowGetter, JS_UNDEFINED, JS_PROP_HAS_GET | JS_PROP_ENUMERABLE);
  JS_FreeAtom(m_ctx, windowKey);
  JS_SetContextOpaque(m_ctx, this);
  JS_SetHostPromiseRejectionTracker(m_runtime, promiseRejectTracker, nullptr);

  m_gcTracker = makeGarbageCollected<ExecutionContextGCTracker>()->initialize(m_ctx, &ExecutionContextGCTracker::contextGcTrackerClassId);
  JS_DefinePropertyValueStr(m_ctx, globalObject, "_gc_tracker_", m_gcTracker->toQuickJS(), JS_PROP_NORMAL);

  runningContexts++;
}

ExecutionContext::~ExecutionContext() {
  valid_contexts[contextId] = false;
  ctxInvalid_ = true;

  // Manual free nodes bound by each other.
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &node_job_list) {
      auto* node = list_entry(el, NodeJob, link);
      JS_FreeValue(m_ctx, node->nodeInstance->jsObject);
    }
  }

  // Manual free moduleListener
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &module_job_list) {
      auto* module = list_entry(el, ModuleContext, link);
      JS_FreeValue(m_ctx, module->callback);
      delete module;
    }
  }

  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &module_callback_job_list) {
      auto* module = list_entry(el, ModuleContext, link);
      JS_FreeValue(m_ctx, module->callback);
      delete module;
    }
  }

  // Free unresolved promise.
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &promise_job_list) {
      auto* promiseContext = list_entry(el, PromiseContext, link);
      JS_FreeValue(m_ctx, promiseContext->resolveFunc);
      JS_FreeValue(m_ctx, promiseContext->rejectFunc);
      delete promiseContext;
    }
  }

  // Free unreleased native_functions.
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &native_function_job_list) {
      auto* job = list_entry(el, NativeFunctionContext, link);
      delete job;
    }
  }

  JS_FreeValue(m_ctx, globalObject);
  JS_FreeContext(m_ctx);

  // Run GC to clean up remaining objects about m_ctx;
  JS_RunGC(m_runtime);

#if DUMP_LEAKS
  if (--runningContexts == 0) {
    JS_FreeRuntime(m_runtime);
    m_runtime = nullptr;
  }
#endif
  m_ctx = nullptr;
}

bool ExecutionContext::evaluateJavaScript(const uint16_t* code, size_t codeLength, const char* sourceURL, int startLine) {
  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t*>(code), codeLength));
  JSValue result = JS_Eval(m_ctx, utf8Code.c_str(), utf8Code.size(), sourceURL, JS_EVAL_TYPE_GLOBAL);
  drainPendingPromiseJobs();
  bool success = handleException(&result);
  JS_FreeValue(m_ctx, result);
  return success;
}

bool ExecutionContext::evaluateJavaScript(const char16_t* code, size_t length, const char* sourceURL, int startLine) {
  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t*>(code), length));
  JSValue result = JS_Eval(m_ctx, utf8Code.c_str(), utf8Code.size(), sourceURL, JS_EVAL_TYPE_GLOBAL);
  drainPendingPromiseJobs();
  bool success = handleException(&result);
  JS_FreeValue(m_ctx, result);
  return success;
}

bool ExecutionContext::evaluateJavaScript(const char* code, size_t codeLength, const char* sourceURL, int startLine) {
  JSValue result = JS_Eval(m_ctx, code, codeLength, sourceURL, JS_EVAL_TYPE_GLOBAL);
  drainPendingPromiseJobs();
  bool success = handleException(&result);
  JS_FreeValue(m_ctx, result);
  return success;
}

bool ExecutionContext::evaluateByteCode(uint8_t* bytes, size_t byteLength) {
  JSValue obj, val;
  obj = JS_ReadObject(m_ctx, bytes, byteLength, JS_READ_OBJ_BYTECODE);
  if (!handleException(&obj))
    return false;
  val = JS_EvalFunction(m_ctx, obj);
  if (!handleException(&val))
    return false;
  JS_FreeValue(m_ctx, val);
  return true;
}

bool ExecutionContext::isValid() const {
  return !ctxInvalid_;
}

int32_t ExecutionContext::getContextId() const {
  assert(!ctxInvalid_ && "context has been released");
  return contextId;
}

void* ExecutionContext::getOwner() {
  assert(!ctxInvalid_ && "context has been released");
  return owner;
}

bool ExecutionContext::handleException(JSValue* exception) {
  if (JS_IsException(*exception)) {
    JSValue error = JS_GetException(m_ctx);
    reportError(error);
    dispatchGlobalErrorEvent(error);
    JS_FreeValue(m_ctx, error);
    return false;
  }

  return true;
}

JSValue ExecutionContext::global() {
  return globalObject;
}

JSContext* ExecutionContext::ctx() {
  assert(!ctxInvalid_ && "context has been released");
  return m_ctx;
}

JSRuntime* ExecutionContext::runtime() {
  return m_runtime;
}

void ExecutionContext::reportError(JSValueConst error) {
  if (!JS_IsError(m_ctx, error))
    return;

  JSValue messageValue = JS_GetPropertyStr(m_ctx, error, "message");
  JSValue errorTypeValue = JS_GetPropertyStr(m_ctx, error, "name");
  const char* title = JS_ToCString(m_ctx, messageValue);
  const char* type = JS_ToCString(m_ctx, errorTypeValue);
  const char* stack = nullptr;
  JSValue stackValue = JS_GetPropertyStr(m_ctx, error, "stack");
  if (!JS_IsUndefined(stackValue)) {
    stack = JS_ToCString(m_ctx, stackValue);
  }

  uint32_t messageLength = strlen(type) + strlen(title);
  if (stack != nullptr) {
    messageLength += 4 + strlen(stack);
    char message[messageLength];
    sprintf(message, "%s: %s\n%s", type, title, stack);
    _handler(contextId, message);
  } else {
    messageLength += 3;
    char message[messageLength];
    sprintf(message, "%s: %s", type, title);
    _handler(contextId, message);
  }

  JS_FreeValue(m_ctx, errorTypeValue);
  JS_FreeValue(m_ctx, messageValue);
  JS_FreeValue(m_ctx, stackValue);
  JS_FreeCString(m_ctx, title);
  JS_FreeCString(m_ctx, stack);
  JS_FreeCString(m_ctx, type);
}

void ExecutionContext::drainPendingPromiseJobs() {
  // should executing pending promise jobs.
  JSContext* pctx;
  int finished = JS_ExecutePendingJob(runtime(), &pctx);
  while (finished != 0) {
    finished = JS_ExecutePendingJob(runtime(), &pctx);
    if (finished == -1) {
      break;
    }
  }
}

void ExecutionContext::defineGlobalProperty(const char* prop, JSValue value) {
  JSAtom atom = JS_NewAtom(m_ctx, prop);
  JS_SetProperty(m_ctx, globalObject, atom, value);
  JS_FreeAtom(m_ctx, atom);
}

uint8_t* ExecutionContext::dumpByteCode(const char* code, uint32_t codeLength, const char* sourceURL, size_t* bytecodeLength) {
  JSValue object = JS_Eval(m_ctx, code, codeLength, sourceURL, JS_EVAL_TYPE_GLOBAL | JS_EVAL_FLAG_COMPILE_ONLY);
  bool success = handleException(&object);
  if (!success)
    return nullptr;
  uint8_t* bytes = JS_WriteObject(m_ctx, bytecodeLength, object, JS_WRITE_OBJ_BYTECODE);
  JS_FreeValue(m_ctx, object);
  return bytes;
}

void ExecutionContext::dispatchGlobalErrorEvent(JSValueConst error) {
  JSValue errorHandler = JS_GetPropertyStr(m_ctx, globalObject, "__global_onerror_handler__");
  JSValue returnValue = JS_Call(m_ctx, errorHandler, globalObject, 1, &error);
  drainPendingPromiseJobs();
  if (JS_IsException(returnValue)) {
    JSValue error = JS_GetException(m_ctx);
    reportError(error);
    JS_FreeValue(m_ctx, error);
  }
  JS_FreeValue(m_ctx, returnValue);
  JS_FreeValue(m_ctx, errorHandler);
}

void ExecutionContext::dispatchGlobalPromiseRejectionEvent(JSValueConst promise, JSValueConst error) {
  JSValue errorHandler = JS_GetPropertyStr(m_ctx, globalObject, "__global_unhandled_promise_handler__");
  JSValue arguments[] = {promise, error};
  JSValue returnValue = JS_Call(m_ctx, errorHandler, globalObject, 2, arguments);
  drainPendingPromiseJobs();
  handleException(&returnValue);
  JS_FreeValue(m_ctx, returnValue);
  JS_FreeValue(m_ctx, errorHandler);
}

void ExecutionContext::promiseRejectTracker(JSContext* ctx, JSValue promise, JSValue reason, int is_handled, void* opaque) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  context->reportError(reason);
  context->dispatchGlobalPromiseRejectionEvent(promise, reason);
}

DOMTimerCoordinator* ExecutionContext::timers() {
  return &m_timers;
}

std::unique_ptr<NativeString> jsValueToNativeString(JSContext* ctx, JSValue value) {
  bool isValueString = true;
  if (JS_IsNull(value)) {
    value = JS_NewString(ctx, "");
    isValueString = false;
  } else if (!JS_IsString(value)) {
    value = JS_ToString(ctx, value);
    isValueString = false;
  }

  uint32_t length;
  uint16_t* buffer = JS_ToUnicode(ctx, value, &length);
  std::unique_ptr<NativeString> ptr = std::make_unique<NativeString>();
  ptr->string = buffer;
  ptr->length = length;

  if (!isValueString) {
    JS_FreeValue(ctx, value);
  }
  return ptr;
}

void buildUICommandArgs(JSContext* ctx, JSValue key, NativeString& args_01) {
  if (!JS_IsString(key))
    return;

  uint32_t length;
  uint16_t* buffer = JS_ToUnicode(ctx, key, &length);
  args_01.string = buffer;
  args_01.length = length;
}

std::unique_ptr<NativeString> stringToNativeString(const std::string& string) {
  std::u16string utf16;
  fromUTF8(string, utf16);
  NativeString tmp{};
  tmp.string = reinterpret_cast<const uint16_t*>(utf16.c_str());
  tmp.length = utf16.size();
  return std::unique_ptr<NativeString>(tmp.clone());
}

std::unique_ptr<NativeString> atomToNativeString(JSContext* ctx, JSAtom atom) {
  JSValue stringValue = JS_AtomToString(ctx, atom);
  std::unique_ptr<NativeString> string = jsValueToNativeString(ctx, stringValue);
  JS_FreeValue(ctx, stringValue);
  return string;
}

std::string jsValueToStdString(JSContext* ctx, JSValue& value) {
  const char* cString = JS_ToCString(ctx, value);
  std::string str = std::string(cString);
  JS_FreeCString(ctx, cString);
  return str;
}

std::string jsAtomToStdString(JSContext* ctx, JSAtom atom) {
  const char* cstr = JS_AtomToCString(ctx, atom);
  std::string str = std::string(cstr);
  JS_FreeCString(ctx, cstr);
  return str;
}

// An lock free context validator.
bool isContextValid(int32_t contextId) {
  if (contextId > running_context_list)
    return false;
  return valid_contexts[contextId];
}

void arrayPushValue(JSContext* ctx, JSValue array, JSValue val) {
  JSValue pushMethod = JS_GetPropertyStr(ctx, array, "push");
  JSValue arguments[] = {val};
  JSValue result = JS_Call(ctx, pushMethod, array, 1, arguments);
  JS_FreeValue(ctx, pushMethod);
  JS_FreeValue(ctx, result);
}

void arraySpliceValue(JSContext* ctx, JSValue array, uint32_t start, uint32_t deleteCount) {
  JSValue spliceMethod = JS_GetPropertyStr(ctx, array, "splice");
  JSValue arguments[] = {JS_NewUint32(ctx, start), JS_NewUint32(ctx, deleteCount)};
  JSValue result = JS_Call(ctx, spliceMethod, array, 2, arguments);
  JS_FreeValue(ctx, spliceMethod);
  JS_FreeValue(ctx, result);
}

void arraySpliceValue(JSContext* ctx, JSValue array, uint32_t start, uint32_t deleteCount, JSValue replacedValue) {
  JSValue spliceMethod = JS_GetPropertyStr(ctx, array, "splice");
  JSValue arguments[] = {JS_NewUint32(ctx, start), JS_NewUint32(ctx, deleteCount), replacedValue};
  JSValue result = JS_Call(ctx, spliceMethod, array, 3, arguments);
  JS_FreeValue(ctx, spliceMethod);
  JS_FreeValue(ctx, result);
}

void arrayInsert(JSContext* ctx, JSValue array, uint32_t start, JSValue targetValue) {
  JSValue spliceMethod = JS_GetPropertyStr(ctx, array, "splice");
  JSValue arguments[] = {JS_NewUint32(ctx, start), JS_NewUint32(ctx, 0), targetValue};
  JSValue result = JS_Call(ctx, spliceMethod, array, 3, arguments);
  JS_FreeValue(ctx, spliceMethod);
  JS_FreeValue(ctx, result);
}

int32_t arrayGetLength(JSContext* ctx, JSValue array) {
  JSValue lenVal = JS_GetPropertyStr(ctx, array, "length");
  int32_t len;
  JS_ToInt32(ctx, &len, lenVal);
  JS_FreeValue(ctx, lenVal);
  return len;
}

int32_t arrayFindIdx(JSContext* ctx, JSValue array, JSValue target) {
  int32_t len = arrayGetLength(ctx, array);
  for (int i = 0; i < len; i++) {
    JSValue v = JS_GetPropertyUint32(ctx, array, i);
    if (JS_VALUE_GET_PTR(v) == JS_VALUE_GET_PTR(target)) {
      JS_FreeValue(ctx, v);
      return i;
    };
    JS_FreeValue(ctx, v);
  }
  return -1;
}

JSValue objectGetKeys(JSContext* ctx, JSValue obj) {
  JSValue globalObject = JS_GetGlobalObject(ctx);
  JSValue object = JS_GetPropertyStr(ctx, globalObject, "Object");
  JSValue keysFunc = JS_GetPropertyStr(ctx, object, "keys");

  JSValue result = JS_Call(ctx, keysFunc, obj, 1, &obj);

  JS_FreeValue(ctx, keysFunc);
  JS_FreeValue(ctx, object);
  JS_FreeValue(ctx, globalObject);

  return result;
}

void ExecutionContext::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  m_timers.trace(rt, JS_NULL, mark_func);
}

}  // namespace kraken::binding::qjs
