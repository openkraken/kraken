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
    JSValue exception = JS_ThrowTypeError(moduleContext->context->ctx(), "Failed to execute '__kraken_invoke_module__': callback is null.");
    context->HandleException(&exception);
    return;
  }

  JSContext* ctx = moduleContext->context->ctx();

  if (errmsg != nullptr) {
    ScriptValue errorObject = ScriptValue::createErrorObject(ctx, errmsg);
    ScriptValue arguments[] = {errorObject};
    ScriptValue returnValue = moduleContext->callback->value()->Invoke(ctx, 1, arguments);
    if (returnValue.IsException()) {
      context->HandleException(&returnValue);
    }
  } else {
    std::u16string argumentString = std::u16string(reinterpret_cast<const char16_t*>(json->string), json->length);
    std::string utf8Arguments = toUTF8(argumentString);
    ScriptValue jsonObject = ScriptValue::createJSONObject(ctx, utf8Arguments.c_str(), utf8Arguments.size());
    ScriptValue arguments[] = {jsonObject};
    ScriptValue returnValue = moduleContext->callback->value()->Invoke(ctx, 1, arguments);
    if (returnValue.IsException()) {
      context->HandleException(&returnValue);
    }
  }

  context->DrainPendingPromiseJobs();
  context->ModuleCallbacks()->RemoveModuleCallbacks(moduleContext->callback);
}

void handleInvokeModuleUnexpectedCallback(void* callbackContext, int32_t contextId, const char* errmsg, NativeString* json) {
  static_assert("Unexpected module callback, please check your invokeModule implementation on the dart side.");
}

std::unique_ptr<NativeString> ModuleManager::__kraken_invoke_module__(ExecutingContext* context,
                                                    std::unique_ptr<NativeString> &moduleName,
                                                    std::unique_ptr<NativeString> &method,
                                                    ExceptionState& exception) {
}

std::unique_ptr<NativeString> ModuleManager::__kraken_invoke_module__(ExecutingContext* context,
                                                    std::unique_ptr<NativeString> &moduleName,
                                                    std::unique_ptr<NativeString> &method,
                                                    ScriptValue& paramsValue,
                                                    ExceptionState& exception) {

}

std::unique_ptr<NativeString> ModuleManager::__kraken_invoke_module__(ExecutingContext* context,
                                                    std::unique_ptr<NativeString> &moduleName,
                                                    std::unique_ptr<NativeString> &method,
                                                    ScriptValue& paramsValue,
                                                    std::shared_ptr<QJSFunction> callback,
                                                    ExceptionState& exception) {

  std::unique_ptr<NativeString> params;
  if (!paramsValue.IsEmpty()) {
    params = paramsValue.ToJSONStringify(&exception).toNativeString();
    if (exception.HasException()) {
      return ScriptValue::Empty(context->ctx());
    }
  }

  if (context->dartMethodPtr()->invokeModule == nullptr) {
    exception.ThrowException(context->ctx(), ErrorType::InternalError, "Failed to execute '__kraken_invoke_module__': dart method (invokeModule) is not registered.");
    return ScriptValue::Empty(context->ctx());
  }

  auto moduleCallback = ModuleCallback::Create(callback);
  context->ModuleCallbacks()->AddModuleCallbacks(moduleCallback);
//
//  ModuleContext* moduleContext = new ModuleContext{context, moduleCallback};
//
//  NativeString* result;
//  if (callback != nullptr) {
//    result = context->dartMethodPtr()->invokeModule(moduleContext, context->getContextId(), moduleName.get(), method.get(), params.get(), handleInvokeModuleTransientCallback);
//  } else {
//    result = context->dartMethodPtr()->invokeModule(moduleContext, context->getContextId(), moduleName.get(), method.get(), params.get(), handleInvokeModuleUnexpectedCallback);
//  }
//
//  moduleName->free();
//  method->free();
//  if (params != nullptr) {
//    params->free();
//  }
//
//  if (result == nullptr) {
//    return ScriptValue::Empty(context->ctx());
//  }
//
//  ScriptValue resultString = ScriptValue::fromNativeString(context->ctx(), result);
//
//  // Manual free returned result string;
//  result->free();

//  return resultString;
}

void ModuleManager::__kraken_add_module_listener__(ExecutingContext* context, std::shared_ptr<QJSFunction> handler, ExceptionState& exception) {
  auto listener = ModuleListener::Create(handler);
  context->ModuleListeners()->addModuleListener(listener);
}

}  // namespace kraken
