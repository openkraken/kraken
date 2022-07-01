/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "native_value_converter.h"

namespace kraken {

#define AnonymousFunctionCallPreFix "_anonymous_fn_"
#define AsyncAnonymousFunctionCallPreFix "_anonymous_async_fn_"

// void call_native_function(NativeFunctionContext* functionContext,
//                          int32_t argc,
//                          NativeValue* argv,
//                          NativeValue* returnValue) {
//  //  auto* context = functionContext->context_;
//  //  auto* arguments = new JSValue[argc];
//  //  for (int i = 0; i < argc; i++) {
//  //    arguments[i] = nativeValueToJSValue(context, argv[i]);
//  //  }
//  //  JSValue result = JS_Call(context->ctx(), functionContext->m_callback, context->Global(), argc, arguments);
//  //  context->DrainPendingPromiseJobs();
//  //  if (context->HandleException(&result)) {
//  //    *returnValue = jsValueToNativeValue(context->ctx(), result);
//  //  }
//  //
//  //  JS_FreeValue(context->ctx(), result);
//  //
//  //  for (int i = 0; i < argc; i++) {
//  //    JS_FreeValue(context->ctx(), arguments[i]);
//  //  }
//  //  delete[] arguments;
//  //  delete functionContext;
//}

static JSValue anonymousFunction(JSContext* ctx,
                                 JSValueConst this_val,
                                 int argc,
                                 JSValueConst* argv,
                                 int magic,
                                 JSValue* func_data) {
  auto id = magic;
  //  auto* eventTarget = static_cast<EventTarget*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  //
  //  std::string call_params = AnonymousFunctionCallPreFix + std::to_string(id);
  //
  //  auto* arguments = new NativeValue[argc];
  //  for (int i = 0; i < argc; i++) {
  //    arguments[i] = jsValueToNativeValue(ctx, argv[i]);
  //  }
  //
  //  JSValue returnValue = eventTarget->callNativeMethods(call_params.c_str(), argc, arguments);
  //  delete[] arguments;
  //  return returnValue;
}

void anonymousAsyncCallback(void* callbackContext, NativeValue* nativeValue, int32_t contextId, const char* errmsg) {
  //  auto* promiseContext = static_cast<PromiseContext*>(callbackContext);
  //  if (!promiseContext->context->IsValid())
  //    return;
  //  if (promiseContext->context->contextId() != contextId)
  //    return;
  //
  //  auto* context = promiseContext->context;
  //
  //  if (nativeValue != nullptr) {
  //    JSValue value = nativeValueToJSValue(promiseContext->context, *nativeValue);
  //    JSValue returnValue = JS_Call(context->ctx(), promiseContext->resolveFunc, context->Global(), 1, &value);
  //    context->DrainPendingPromiseJobs();
  //    context->HandleException(&returnValue);
  //    JS_FreeValue(context->ctx(), value);
  //    JS_FreeValue(context->ctx(), returnValue);
  //  } else if (errmsg != nullptr) {
  //    JSValue error = JS_NewError(context->ctx());
  //    JS_DefinePropertyValueStr(context->ctx(), error, "message", JS_NewString(context->ctx(), errmsg),
  //    JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE); JSValue returnValue = JS_Call(context->ctx(),
  //    promiseContext->rejectFunc, context->Global(), 1, &error); context->DrainPendingPromiseJobs();
  //    context->HandleException(&returnValue);
  //    JS_FreeValue(context->ctx(), error);
  //    JS_FreeValue(context->ctx(), returnValue);
  //  }
  //
  //  JS_FreeValue(context->ctx(), promiseContext->resolveFunc);
  //  JS_FreeValue(context->ctx(), promiseContext->rejectFunc);
  //  list_del(&promiseContext->link);
}

static JSValue anonymousAsyncFunction(JSContext* ctx,
                                      JSValueConst this_val,
                                      int argc,
                                      JSValueConst* argv,
                                      int magic,
                                      JSValue* func_data) {
  //  JSValue resolving_funcs[2];
  //  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);
  //
  //  auto id = magic;
  //  auto* eventTarget = static_cast<EventTargetInstance*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  //  auto* context = eventTarget->context();
  //
  //  auto* promiseContext = new PromiseContext{eventTarget, context, resolving_funcs[0], resolving_funcs[1], promise};
  //  list_add_tail(&promiseContext->link, &context->promise_job_list);
  //
  //  std::string call_params = AsyncAnonymousFunctionCallPreFix + std::to_string(id);
  //
  //  auto* arguments = new NativeValue[argc + 3];
  //
  //  arguments[0] = Native_NewInt32(context->getContextId());
  //  arguments[1] = Native_NewPtr(JSPointerType::AsyncContextContext, promiseContext);
  //  arguments[2] = Native_NewPtr(JSPointerType::AsyncContextContext, reinterpret_cast<void*>(anonymousAsyncCallback));
  //  for (int i = 0; i < argc; i++) {
  //    arguments[i + 3] = jsValueToNativeValue(ctx, argv[i]);
  //  }
  //
  //  eventTarget->callNativeMethods(call_params.c_str(), argc + 3, arguments);
  //  delete[] arguments;
  //
  //  return promise;
  return JS_NULL;
}

std::shared_ptr<QJSFunction> CreateSyncCallback(JSContext* ctx, int function_id) {
  JSValue callback = JS_NewCFunctionData(ctx, anonymousFunction, 4, function_id, 0, nullptr);
  auto result = QJSFunction::Create(ctx, callback);
  JS_FreeValue(ctx, callback);
  return result;
}

std::shared_ptr<QJSFunction> CreateAsyncCallback(JSContext* ctx, int function_id) {
  JSValue callback = JS_NewCFunctionData(ctx, anonymousAsyncFunction, 4, function_id, 0, nullptr);
  auto result = QJSFunction::Create(ctx, callback);
  JS_FreeValue(ctx, callback);
  return result;
}

}  // namespace kraken
