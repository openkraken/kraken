/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "executing_context.h"

namespace kraken {

static std::atomic<int32_t> context_unique_id{0};

std::atomic<int32_t> runningContexts{0};

#define MAX_JS_CONTEXT 1024
bool valid_contexts[MAX_JS_CONTEXT];
std::atomic<uint32_t> running_context_list{0};

std::unique_ptr<ExecutionContext> createJSContext(int32_t contextId, const JSExceptionHandler& handler, void* owner) {
  return std::make_unique<ExecutionContext>(contextId, handler, owner);
}

static JSRuntime* m_runtime{nullptr};

void ExecutionContextGCTracker::trace(Visitor* visitor) const {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(m_ctx));
  context->trace(visitor);
}
void ExecutionContextGCTracker::dispose() const {}

JSClassID ExecutionContextGCTracker::contextGcTrackerClassId{0};

ExecutionContext::ExecutionContext(int32_t contextId, const JSExceptionHandler& handler, void* owner)
    : contextId(contextId), _handler(handler), owner(owner), ctxInvalid_(false), uniqueId(context_unique_id++) {
  // @FIXME: maybe contextId will larger than MAX_JS_CONTEXT
  valid_contexts[contextId] = true;
  if (contextId > running_context_list)
    running_context_list = contextId;

  init_list_head(&node_job_list);
  init_list_head(&module_job_list);
  init_list_head(&module_callback_job_list);
  init_list_head(&promise_job_list);
  init_list_head(&native_function_job_list);

  if (m_runtime == nullptr) {
    m_runtime = JS_NewRuntime();
  }
  // Avoid stack overflow when running in multiple threads.
  JS_UpdateStackTop(m_runtime);
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

  m_gcTracker = makeGarbageCollected<ExecutionContextGCTracker>()->initialize<ExecutionContextGCTracker>(m_ctx, &ExecutionContextGCTracker::contextGcTrackerClassId);
  JS_DefinePropertyValueStr(m_ctx, globalObject, "_gc_tracker_", m_gcTracker->toQuickJS(), JS_PROP_NORMAL);

  runningContexts++;
}

ExecutionContext::~ExecutionContext() {
  valid_contexts[contextId] = false;
  ctxInvalid_ = true;

  // Manual free nodes bound by each other.
  //  {
  //    struct list_head *el, *el1;
  //    list_for_each_safe(el, el1, &node_job_list) {
  //      auto* node = list_entry(el, NodeJob, link);
  //      JS_FreeValue(m_ctx, node->nodeInstance->jsObject);
  //    }
  //  }
  //
  //  // Manual free moduleListener
  //  {
  //    struct list_head *el, *el1;
  //    list_for_each_safe(el, el1, &module_job_list) {
  //      auto* module = list_entry(el, ModuleContext, link);
  //      JS_FreeValue(m_ctx, module->callback);
  //      delete module;
  //    }
  //  }
  //
  //  {
  //    struct list_head *el, *el1;
  //    list_for_each_safe(el, el1, &module_callback_job_list) {
  //      auto* module = list_entry(el, ModuleContext, link);
  //      JS_FreeValue(m_ctx, module->callback);
  //      delete module;
  //    }
  //  }

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

  // Check if current context have unhandled exceptions.
  JSValue exception = JS_GetException(m_ctx);
  if (JS_IsObject(exception) || JS_IsException(exception)) {
    // There must be bugs in native functions from call stack frame. Someone needs to fix it if throws.
    reportError(exception);
    assert_m(false, "Unhandled exception found when dispose JSContext.");
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

void* ExecutionContext::getOwner() {
  assert(!ctxInvalid_ && "context has been released");
  return owner;
}

bool ExecutionContext::handleException(JSValue* exc) {
  if (JS_IsException(*exc)) {
    JSValue error = JS_GetException(m_ctx);
    reportError(error);
    dispatchGlobalErrorEvent(this, error);
    JS_FreeValue(m_ctx, error);
    return false;
  }

  return true;
}

bool ExecutionContext::handleException(ScriptValue* exc) {
  JSValue value = exc->toQuickJS();
  handleException(&value);
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

  // Throw error when promise are not handled.
  m_rejectedPromise.process(this);
}

void ExecutionContext::defineGlobalProperty(const char* prop, JSValue value) {
  JSAtom atom = JS_NewAtom(m_ctx, prop);
  JS_SetProperty(m_ctx, globalObject, atom, value);
  JS_FreeAtom(m_ctx, atom);
}

ExecutionContextData* ExecutionContext::contextData() {
  return &m_data;
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

void ExecutionContext::dispatchGlobalErrorEvent(ExecutionContext* context, JSValueConst error) {
//  JSContext* ctx = context->ctx();
//  auto* window = static_cast<Window*>(JS_GetOpaque(context->global(), Window::classId()));
//
//  {
//    JSValue ErrorEventValue = JS_GetPropertyStr(ctx, context->global(), "ErrorEvent");
//    JSValue errorType = JS_NewString(ctx, "error");
//    JSValue errorInit = JS_NewObject(ctx);
//    JS_SetPropertyStr(ctx, errorInit, "error", JS_DupValue(ctx, error));
//    JS_SetPropertyStr(ctx, errorInit, "message", JS_GetPropertyStr(ctx, error, "message"));
//    JS_SetPropertyStr(ctx, errorInit, "lineno", JS_GetPropertyStr(ctx, error, "lineNumber"));
//    JS_SetPropertyStr(ctx, errorInit, "filename", JS_GetPropertyStr(ctx, error, "fileName"));
//    JS_SetPropertyStr(ctx, errorInit, "colno", JS_NewUint32(ctx, 0));
//    JSValue arguments[] = {errorType, errorInit};
//    JSValue errorEventValue = JS_CallConstructor(context->ctx(), ErrorEventValue, 2, arguments);
//    if (JS_IsException(errorEventValue)) {
//      context->handleException(&errorEventValue);
//      return;
//    }
//
//    auto* errorEvent = static_cast<EventInstance*>(JS_GetOpaque(errorEventValue, Event::kEventClassID));
//    window->dispatchEvent(errorEvent);
//
//    JS_FreeValue(ctx, ErrorEventValue);
//    JS_FreeValue(ctx, errorEventValue);
//    JS_FreeValue(ctx, errorType);
//    JS_FreeValue(ctx, errorInit);
//
//    context->drainPendingPromiseJobs();
//  }
}

static void dispatchPromiseRejectionEvent(const char* eventType, ExecutionContext* context, JSValueConst promise, JSValueConst error) {
//  JSContext* ctx = context->ctx();
//  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(context->global(), Window::classId()));
//
//  // Trigger PromiseRejectionEvent(unhandledrejection) event.
//  {
//    JSValue PromiseRejectionEventValue = JS_GetPropertyStr(ctx, context->global(), "PromiseRejectionEvent");
//    JSValue errorType = JS_NewString(ctx, eventType);
//    JSValue errorInit = JS_NewObject(ctx);
//    JS_SetPropertyStr(ctx, errorInit, "promise", JS_DupValue(ctx, promise));
//    JS_SetPropertyStr(ctx, errorInit, "reason", JS_DupValue(ctx, error));
//    JSValue arguments[] = {errorType, errorInit};
//    JSValue rejectEventValue = JS_CallConstructor(context->ctx(), PromiseRejectionEventValue, 2, arguments);
//    if (JS_IsException(rejectEventValue)) {
//      context->handleException(&rejectEventValue);
//      return;
//    }
//
//    auto* rejectEvent = static_cast<EventInstance*>(JS_GetOpaque(rejectEventValue, Event::kEventClassID));
//    window->dispatchEvent(rejectEvent);
//
//    JS_FreeValue(ctx, errorType);
//    JS_FreeValue(ctx, errorInit);
//    JS_FreeValue(ctx, rejectEventValue);
//    JS_FreeValue(ctx, PromiseRejectionEventValue);
//
//    context->drainPendingPromiseJobs();
//  }
}

void ExecutionContext::dispatchGlobalUnhandledRejectionEvent(ExecutionContext* context, JSValueConst promise, JSValueConst error) {
  // Trigger onerror event.
  dispatchGlobalErrorEvent(context, error);

  // Trigger unhandledRejection event.
  dispatchPromiseRejectionEvent("unhandledrejection", context, promise, error);
}

void ExecutionContext::dispatchGlobalRejectionHandledEvent(ExecutionContext* context, JSValue promise, JSValue error) {
  // Trigger rejectionhandled event.
  dispatchPromiseRejectionEvent("rejectionhandled", context, promise, error);
}

void ExecutionContext::promiseRejectTracker(JSContext* ctx, JSValue promise, JSValue reason, int is_handled, void* opaque) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  // The unhandledrejection event is the promise-equivalent of the global error event, which is fired for uncaught exceptions.
  // Because a rejected promise could be handled after the fact, by attaching catch(onRejected) or then(onFulfilled, onRejected) to it,
  // the additional rejectionhandled event is needed to indicate that a promise which was previously rejected should no longer be considered unhandled.
  if (is_handled) {
    context->m_rejectedPromise.trackHandledPromiseRejection(context, promise, reason);
  } else {
    context->m_rejectedPromise.trackUnhandledPromiseRejection(context, promise, reason);
  }
}

void installFunctionProperty(ExecutionContext* context, JSValue thisObject, const char* functionName, JSCFunction function, int argc) {
  JSValue f = JS_NewCFunction(context->ctx(), function, functionName, argc);
  JSValue pf = JS_NewCFunctionData(context->ctx(), handleCallThisOnProxy, argc, 0, 1, &f);
  JSAtom key = JS_NewAtom(context->ctx(), functionName);

  JS_FreeValue(context->ctx(), f);

// We should avoid overwrite exist property functions.
#ifdef DEBUG
  assert_m(JS_HasProperty(context->ctx(), thisObject, key) == 0, (std::string("Found exist function property: ") + std::string(functionName)).c_str());
#endif

  JS_DefinePropertyValue(context->ctx(), thisObject, key, pf, JS_PROP_ENUMERABLE);
  JS_FreeAtom(context->ctx(), key);
}

void installPropertyGetterSetter(ExecutionContext* context, JSValue thisObject, const char* property, JSCFunction getterFunction, JSCFunction setterFunction) {
  // Getter on jsObject works well with all conditions.
  // We create an getter function and define to jsObject directly.
  JSAtom propertyKeyAtom = JS_NewAtom(context->ctx(), property);
  JSValue getter = JS_NewCFunction(context->ctx(), getterFunction, "getter", 0);
  JSValue getterProxy = JS_NewCFunctionData(context->ctx(), handleCallThisOnProxy, 0, 0, 1, &getter);

  // Getter on jsObject works well with all conditions.
  // We create an getter function and define to jsObject directly.
  JSValue setter = JS_NewCFunction(context->ctx(), setterFunction, "setter", 0);
  JSValue setterProxy = JS_NewCFunctionData(context->ctx(), handleCallThisOnProxy, 1, 0, 1, &setter);

  // Define getter and setter property.
  JS_DefinePropertyGetSet(context->ctx(), thisObject, propertyKeyAtom, getterProxy, setterProxy, JS_PROP_NORMAL | JS_PROP_ENUMERABLE);

  JS_FreeAtom(context->ctx(), propertyKeyAtom);
  JS_FreeValue(context->ctx(), getter);
  JS_FreeValue(context->ctx(), setter);
}

void installPropertyGetter(ExecutionContext* context, JSValue thisObject, const char* property, JSCFunction getterFunction) {
  // Getter on jsObject works well with all conditions.
  // We create an getter function and define to jsObject directly.
  JSAtom propertyKeyAtom = JS_NewAtom(context->ctx(), property);
  JSValue getter = JS_NewCFunction(context->ctx(), getterFunction, "getter", 0);
  JSValue getterProxy = JS_NewCFunctionData(context->ctx(), handleCallThisOnProxy, 0, 0, 1, &getter);
  JS_DefinePropertyGetSet(context->ctx(), thisObject, propertyKeyAtom, getterProxy, JS_UNDEFINED, JS_PROP_NORMAL | JS_PROP_ENUMERABLE);
  JS_FreeAtom(context->ctx(), propertyKeyAtom);
  JS_FreeValue(context->ctx(), getter);
}

DOMTimerCoordinator* ExecutionContext::timers() {
  return &m_timers;
}

void ExecutionContext::trace(Visitor* visitor) {
  m_timers.trace(visitor);
}

void buildUICommandArgs(JSContext* ctx, JSValue key, NativeString& args_01) {
  if (!JS_IsString(key))
    return;

  uint32_t length;
  uint16_t* buffer = JS_ToUnicode(ctx, key, &length);
  args_01.string = buffer;
  args_01.length = length;
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

}  // namespace kraken
