/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_manager.h"
#include "core/executing_context.h"
#include "module_callback.h"

namespace kraken {

struct ModuleContext {
  ExecutingContext* context;
  std::shared_ptr<ModuleCallback> callback;
};

void handleInvokeModuleTransientCallback(void* ptr, int32_t contextId, const char* errmsg, NativeString* json) {
  auto* moduleContext = static_cast<ModuleContext*>(ptr);
  ExecutingContext* context = moduleContext->context;

  if (!context->IsValid())
    return;

  if (moduleContext->callback == nullptr) {
    JSValue exception = JS_ThrowTypeError(moduleContext->context->ctx(),
                                          "Failed to execute '__kraken_invoke_module__': callback is null.");
    context->HandleException(&exception);
    return;
  }

  JSContext* ctx = moduleContext->context->ctx();

  if (errmsg != nullptr) {
    ScriptValue errorObject = ScriptValue::createErrorObject(ctx, errmsg);
    ScriptValue arguments[] = {errorObject};
    ScriptValue returnValue = moduleContext->callback->value()->Invoke(ctx, ScriptValue::Empty(ctx), 1, arguments);
    if (returnValue.IsException()) {
      context->HandleException(&returnValue);
    }
  } else {
    std::u16string argumentString = std::u16string(reinterpret_cast<const char16_t*>(json->string()), json->length());
    std::string utf8Arguments = toUTF8(argumentString);
    ScriptValue jsonObject = ScriptValue::createJSONObject(ctx, utf8Arguments.c_str(), utf8Arguments.size());
    ScriptValue arguments[] = {jsonObject};
    ScriptValue returnValue = moduleContext->callback->value()->Invoke(ctx, ScriptValue::Empty(ctx), 1, arguments);
    if (returnValue.IsException()) {
      context->HandleException(&returnValue);
    }
  }

  context->DrainPendingPromiseJobs();
  context->ModuleCallbacks()->RemoveModuleCallbacks(moduleContext->callback);

  delete moduleContext;
}

void handleInvokeModuleUnexpectedCallback(void* callbackContext,
                                          int32_t contextId,
                                          const char* errmsg,
                                          NativeString* json) {
  static_assert("Unexpected module callback, please check your invokeModule implementation on the dart side.");
}

AtomicString ModuleManager::__kraken_invoke_module__(ExecutingContext* context,
                                                     const AtomicString& moduleName,
                                                     const AtomicString& method,
                                                     ExceptionState& exception) {
  ScriptValue empty = ScriptValue::Empty(context->ctx());
  return __kraken_invoke_module__(context, moduleName, method, empty, nullptr, exception);
}

AtomicString ModuleManager::__kraken_invoke_module__(ExecutingContext* context,
                                                     const AtomicString& moduleName,
                                                     const AtomicString& method,
                                                     ScriptValue& paramsValue,
                                                     ExceptionState& exception) {
  return __kraken_invoke_module__(context, moduleName, method, paramsValue, nullptr, exception);
}

AtomicString ModuleManager::__kraken_invoke_module__(ExecutingContext* context,
                                                     const AtomicString& moduleName,
                                                     const AtomicString& method,
                                                     ScriptValue& paramsValue,
                                                     std::shared_ptr<QJSFunction> callback,
                                                     ExceptionState& exception) {
  std::unique_ptr<NativeString> params;
  if (!paramsValue.IsEmpty()) {
    params = paramsValue.ToJSONStringify(&exception).toNativeString();
    if (exception.HasException()) {
      return AtomicString::Empty(context->ctx());
    }
  }

  if (context->dartMethodPtr()->invokeModule == nullptr) {
    exception.ThrowException(
        context->ctx(), ErrorType::InternalError,
        "Failed to execute '__kraken_invoke_module__': dart method (invokeModule) is not registered.");
    return AtomicString::Empty(context->ctx());
  }

  auto moduleCallback = ModuleCallback::Create(callback);
  context->ModuleCallbacks()->AddModuleCallbacks(std::move(moduleCallback));
  ModuleContext* moduleContext = new ModuleContext{context, moduleCallback};

  NativeString* result;
  if (callback != nullptr) {
    result = context->dartMethodPtr()->invokeModule(moduleContext, context->contextId(),
                                                    moduleName.ToNativeString().get(), method.ToNativeString().get(),
                                                    params.get(), handleInvokeModuleTransientCallback);
  } else {
    result = context->dartMethodPtr()->invokeModule(moduleContext, context->contextId(),
                                                    moduleName.ToNativeString().get(), method.ToNativeString().get(),
                                                    params.get(), handleInvokeModuleUnexpectedCallback);
  }

  if (result == nullptr) {
    return AtomicString::Empty(context->ctx());
  }

  return AtomicString::From(context->ctx(), result);
}

void ModuleManager::__kraken_add_module_listener__(ExecutingContext* context,
                                                   const std::shared_ptr<QJSFunction>& handler,
                                                   ExceptionState& exception) {
  auto listener = ModuleListener::Create(handler);
  context->ModuleListeners()->AddModuleListener(listener);
}

}  // namespace kraken
