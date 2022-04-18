/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "executing_context.h"
#include "built_in_string.h"
#include "event_type_names.h"
#include "polyfill.h"
#include "core/dom/document.h"

#include "foundation/logging.h"

namespace kraken {

static std::atomic<int32_t> context_unique_id{0};

#define MAX_JS_CONTEXT 1024
bool valid_contexts[MAX_JS_CONTEXT];
std::atomic<uint32_t> running_context_list{0};

std::unique_ptr<ExecutingContext> createJSContext(int32_t contextId, const JSExceptionHandler& handler, void* owner) {
  return std::make_unique<ExecutingContext>(contextId, handler, owner);
}

ExecutingContext::ExecutingContext(int32_t contextId, const JSExceptionHandler& handler, void* owner)
    : context_id_(contextId), handler_(handler), owner_(owner), ctx_invalid_(false), unique_id_(context_unique_id++) {
#if ENABLE_PROFILE
  auto jsContextStartTime =
      std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch())
          .count();
  auto nativePerformance = Performance::instance(m_context)->m_nativePerformance;
  nativePerformance.mark(PERF_JS_CONTEXT_INIT_START, jsContextStartTime);
  nativePerformance.mark(PERF_JS_CONTEXT_INIT_END);
  nativePerformance.mark(PERF_JS_NATIVE_METHOD_INIT_START);
#endif

  // @FIXME: maybe contextId will larger than MAX_JS_CONTEXT
  valid_contexts[contextId] = true;
  if (contextId > running_context_list)
    running_context_list = contextId;

  init_list_head(&node_job_list);
  init_list_head(&module_job_list);
  init_list_head(&module_callback_job_list);

  time_origin_ = std::chrono::system_clock::now();

  JSContext* ctx = script_state_.ctx();
  global_object_ = JS_GetGlobalObject(script_state_.ctx());
  JSValue windowGetter = JS_NewCFunction(
      ctx,
      [](JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) -> JSValue {
        return JS_GetGlobalObject(ctx);
      },
      "get", 0);
  JSAtom windowKey = JS_NewAtom(ctx, "window");
  JS_DefinePropertyGetSet(ctx, global_object_, windowKey, windowGetter, JS_UNDEFINED,
                          JS_PROP_HAS_GET | JS_PROP_ENUMERABLE);
  JS_FreeAtom(ctx, windowKey);
  JS_SetContextOpaque(ctx, this);
  JS_SetHostPromiseRejectionTracker(script_state_.runtime(), promiseRejectTracker, nullptr);

  // Register all built-in native bindings.
  InstallBindings(this);


  InstallDocument();

#if ENABLE_PROFILE
  nativePerformance.mark(PERF_JS_NATIVE_METHOD_INIT_END);
  nativePerformance.mark(PERF_JS_POLYFILL_INIT_START);
#endif

  initKrakenPolyFill(this);

  for (auto& p : pluginByteCode) {
    EvaluateByteCode(p.second.bytes, p.second.length);
  }

#if ENABLE_PROFILE
  nativePerformance.mark(PERF_JS_POLYFILL_INIT_END);
#endif
}

ExecutingContext::~ExecutingContext() {
  valid_contexts[context_id_] = false;
  ctx_invalid_ = true;

  // Check if current context have unhandled exceptions.
  JSValue exception = JS_GetException(script_state_.ctx());
  if (JS_IsObject(exception) || JS_IsException(exception)) {
    // There must be bugs in native functions from call stack frame. Someone needs to fix it if throws.
    ReportError(exception);
    assert_m(false, "Unhandled exception found when Dispose JSContext.");
  }

  JS_FreeValue(script_state_.ctx(), global_object_);
}

ExecutingContext* ExecutingContext::From(JSContext* ctx) {
  return static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
}

bool ExecutingContext::EvaluateJavaScript(const uint16_t* code,
                                          size_t codeLength,
                                          const char* sourceURL,
                                          int startLine) {
  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t*>(code), codeLength));
  JSValue result = JS_Eval(script_state_.ctx(), utf8Code.c_str(), utf8Code.size(), sourceURL, JS_EVAL_TYPE_GLOBAL);
  DrainPendingPromiseJobs();
  bool success = HandleException(&result);
  JS_FreeValue(script_state_.ctx(), result);
  return success;
}

bool ExecutingContext::EvaluateJavaScript(const char16_t* code, size_t length, const char* sourceURL, int startLine) {
  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t*>(code), length));
  JSValue result = JS_Eval(script_state_.ctx(), utf8Code.c_str(), utf8Code.size(), sourceURL, JS_EVAL_TYPE_GLOBAL);
  DrainPendingPromiseJobs();
  bool success = HandleException(&result);
  JS_FreeValue(script_state_.ctx(), result);
  return success;
}

bool ExecutingContext::EvaluateJavaScript(const char* code, size_t codeLength, const char* sourceURL, int startLine) {
  JSValue result = JS_Eval(script_state_.ctx(), code, codeLength, sourceURL, JS_EVAL_TYPE_GLOBAL);
  DrainPendingPromiseJobs();
  bool success = HandleException(&result);
  JS_FreeValue(script_state_.ctx(), result);
  return success;
}

bool ExecutingContext::EvaluateByteCode(uint8_t* bytes, size_t byteLength) {
  JSValue obj, val;
  obj = JS_ReadObject(script_state_.ctx(), bytes, byteLength, JS_READ_OBJ_BYTECODE);
  if (!HandleException(&obj))
    return false;
  val = JS_EvalFunction(script_state_.ctx(), obj);
  if (!HandleException(&val))
    return false;
  JS_FreeValue(script_state_.ctx(), val);
  return true;
}

bool ExecutingContext::IsValid() const {
  return !ctx_invalid_;
}

void* ExecutingContext::owner() {
  assert(!ctx_invalid_ && "GetExecutingContext has been released");
  return owner_;
}

bool ExecutingContext::HandleException(JSValue* exc) {
  if (JS_IsException(*exc)) {
    JSValue error = JS_GetException(script_state_.ctx());
    ReportError(error);
    DispatchGlobalErrorEvent(this, error);
    JS_FreeValue(script_state_.ctx(), error);
    return false;
  }

  return true;
}

bool ExecutingContext::HandleException(ScriptValue* exc) {
  JSValue value = exc->QJSValue();
  return HandleException(&value);
}

JSValue ExecutingContext::Global() {
  return global_object_;
}

JSContext* ExecutingContext::ctx() {
  assert(!ctx_invalid_ && "GetExecutingContext has been released");
  return script_state_.ctx();
}

void ExecutingContext::ReportError(JSValueConst error) {
  JSContext* ctx = script_state_.ctx();
  if (!JS_IsError(ctx, error))
    return;

  JSValue messageValue = JS_GetPropertyStr(ctx, error, "message");
  JSValue errorTypeValue = JS_GetPropertyStr(ctx, error, "name");
  const char* title = JS_ToCString(ctx, messageValue);
  const char* type = JS_ToCString(ctx, errorTypeValue);
  const char* stack = nullptr;
  JSValue stackValue = JS_GetPropertyStr(ctx, error, "stack");
  if (!JS_IsUndefined(stackValue)) {
    stack = JS_ToCString(ctx, stackValue);
  }

  uint32_t messageLength = strlen(type) + strlen(title);
  if (stack != nullptr) {
    messageLength += 4 + strlen(stack);
    char message[messageLength];
    sprintf(message, "%s: %s\n%s", type, title, stack);
    handler_(this, message);
  } else {
    messageLength += 3;
    char message[messageLength];
    sprintf(message, "%s: %s", type, title);
    handler_(this, message);
  }

  JS_FreeValue(ctx, errorTypeValue);
  JS_FreeValue(ctx, messageValue);
  JS_FreeValue(ctx, stackValue);
  JS_FreeCString(ctx, title);
  JS_FreeCString(ctx, stack);
  JS_FreeCString(ctx, type);
}

void ExecutingContext::DrainPendingPromiseJobs() {
  // should executing pending promise jobs.
  JSContext* pctx;
  int finished = JS_ExecutePendingJob(script_state_.runtime(), &pctx);
  while (finished != 0) {
    finished = JS_ExecutePendingJob(script_state_.runtime(), &pctx);
    if (finished == -1) {
      break;
    }
  }

  // Throw error when promise are not handled.
  rejected_promises_.Process(this);
}

void ExecutingContext::DefineGlobalProperty(const char* prop, JSValue value) {
  JSAtom atom = JS_NewAtom(script_state_.ctx(), prop);
  JS_SetProperty(script_state_.ctx(), global_object_, atom, value);
  JS_FreeAtom(script_state_.ctx(), atom);
}

ExecutionContextData* ExecutingContext::contextData() {
  return &context_data_;
}

uint8_t* ExecutingContext::DumpByteCode(const char* code,
                                        uint32_t codeLength,
                                        const char* sourceURL,
                                        size_t* bytecodeLength) {
  JSValue object =
      JS_Eval(script_state_.ctx(), code, codeLength, sourceURL, JS_EVAL_TYPE_GLOBAL | JS_EVAL_FLAG_COMPILE_ONLY);
  bool success = HandleException(&object);
  if (!success)
    return nullptr;
  uint8_t* bytes = JS_WriteObject(script_state_.ctx(), bytecodeLength, object, JS_WRITE_OBJ_BYTECODE);
  JS_FreeValue(script_state_.ctx(), object);
  return bytes;
}

void ExecutingContext::DispatchGlobalErrorEvent(ExecutingContext* context, JSValueConst error) {
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

static void dispatchPromiseRejectionEvent(const char* eventType,
                                          ExecutingContext* context,
                                          JSValueConst promise,
                                          JSValueConst error) {
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

void ExecutingContext::DispatchGlobalUnhandledRejectionEvent(ExecutingContext* context,
                                                             JSValueConst promise,
                                                             JSValueConst error) {
  // Trigger onerror event.
  DispatchGlobalErrorEvent(context, error);

  // Trigger unhandledRejection event.
  dispatchPromiseRejectionEvent("unhandledrejection", context, promise, error);
}

void ExecutingContext::DispatchGlobalRejectionHandledEvent(ExecutingContext* context, JSValue promise, JSValue error) {
  // Trigger rejectionhandled event.
  dispatchPromiseRejectionEvent("rejectionhandled", context, promise, error);
}

std::unordered_map<std::string, NativeByteCode> ExecutingContext::pluginByteCode{};

void ExecutingContext::promiseRejectTracker(JSContext* ctx,
                                            JSValue promise,
                                            JSValue reason,
                                            int is_handled,
                                            void* opaque) {
  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
  // The unhandledrejection event is the promise-equivalent of the global error event, which is fired for uncaught
  // exceptions. Because a rejected promise could be handled after the fact, by attaching catch(onRejected) or
  // then(onFulfilled, onRejected) to it, the additional rejectionhandled event is needed to indicate that a promise
  // which was previously rejected should no longer be considered unhandled.
  if (is_handled) {
    context->rejected_promises_.TrackHandledPromiseRejection(context, promise, reason);
  } else {
    context->rejected_promises_.TrackUnhandledPromiseRejection(context, promise, reason);
  }
}

DOMTimerCoordinator* ExecutingContext::Timers() {
  return &timers_;
}

ModuleListenerContainer* ExecutingContext::ModuleListeners() {
  return &module_listener_container_;
}

ModuleCallbackCoordinator* ExecutingContext::ModuleCallbacks() {
  return &module_callbacks_;
}

// PendingPromises* ExecutingContext::PendingPromises() {
//  return &pending_promises_;
//}

void ExecutingContext::InstallDocument() {
  document_ = MakeGarbageCollected<Document>(this);
  DefineGlobalProperty("document", document_->ToQuickJS());
}

// An lock free context validator.
bool isContextValid(int32_t contextId) {
  if (contextId > running_context_list)
    return false;
  return valid_contexts[contextId];
}

}  // namespace kraken
