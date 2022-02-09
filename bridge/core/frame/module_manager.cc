/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_manager.h"
#include "core/executing_context.h"
#include "module_callback.h"

namespace kraken {

struct ModuleContext {
  ExecutionContext* context;
  ModuleCallback* callback;
};

void handleInvokeModuleTransientCallback(void* ptr, int32_t contextId, const char* errmsg, NativeString* json) {
  auto* moduleContext = static_cast<ModuleContext*>(ptr);
  ExecutionContext* context = moduleContext->context;

  if (!context->isValid())
    return;

  if (moduleContext->callback == nullptr) {
    JSValue exception = JS_ThrowTypeError(moduleContext->context->ctx(), "Failed to execute '__kraken_invoke_module__': callback is null.");
    context->handleException(&exception);
    return;
  }

  JSContext* ctx = moduleContext->context->ctx();

  if (errmsg != nullptr) {
    ScriptValue errorObject = ScriptValue::createErrorObject(ctx, errmsg);
    ScriptValue arguments[] = {errorObject};
    ScriptValue returnValue = moduleContext->callback->value()->invoke(ctx, 1, arguments);
    if (returnValue.isException()) {
      context->handleException(&returnValue);
    }
  } else {
    std::u16string argumentString = std::u16string(reinterpret_cast<const char16_t*>(json->string), json->length);
    std::string utf8Arguments = toUTF8(argumentString);
    ScriptValue jsonObject = ScriptValue::createJSONObject(ctx, utf8Arguments.c_str(), utf8Arguments.size());
    ScriptValue arguments[] = {jsonObject};
    ScriptValue returnValue = moduleContext->callback->value()->invoke(ctx, 1, arguments);
    if (returnValue.isException()) {
      context->handleException(&returnValue);
    }
  }

  context->drainPendingPromiseJobs();
  context->moduleCallbacks()->removeModuleCallbacks(moduleContext->callback);
}

void handleInvokeModuleUnexpectedCallback(void* callbackContext, int32_t contextId, const char* errmsg, NativeString* json) {
  static_assert("Unexpected module callback, please check your invokeModule implementation on the dart side.");
}

ScriptValue ModuleManager::invokeModule(ExecutionContext* context, ScriptValue& moduleNameValue, ScriptValue& methodValue, ScriptValue& paramsValue, QJSFunction* callback, ExceptionState* exception) {
  std::unique_ptr<NativeString> moduleName = moduleNameValue.toNativeString();
  std::unique_ptr<NativeString> method = methodValue.toNativeString();
  std::unique_ptr<NativeString> params;
  if (!paramsValue.isEmpty()) {
    ScriptValue stringifiedValue = paramsValue.toJSONStringify(exception);
    if (exception->hasException()) {
      return stringifiedValue;
    }

    params = stringifiedValue.toNativeString();
  }

  if (context->dartMethodPtr()->invokeModule == nullptr) {
    exception->throwException(context->ctx(), ErrorType::InternalError, "Failed to execute '__kraken_invoke_module__': dart method (invokeModule) is not registered.");
    return ScriptValue(context->ctx());
  }

  auto* moduleCallback = makeGarbageCollected<ModuleCallback>(callback);
  context->moduleCallbacks()->addModuleCallbacks(moduleCallback);

  ModuleContext* moduleContext = new ModuleContext{context, moduleCallback};

  NativeString* result;
  if (callback != nullptr) {
    result = context->dartMethodPtr()->invokeModule(moduleContext, context->getContextId(), moduleName.get(), method.get(), params.get(), handleInvokeModuleTransientCallback);
  } else {
    result = context->dartMethodPtr()->invokeModule(moduleContext, context->getContextId(), moduleName.get(), method.get(), params.get(), handleInvokeModuleUnexpectedCallback);
  }

  moduleName->free();
  method->free();
  if (params != nullptr) {
    params->free();
  }

  if (result == nullptr) {
    return ScriptValue::Empty(context->ctx());
  }

  ScriptValue resultString = ScriptValue::fromNativeString(context->ctx(), result);

  // Manual free returned result string;
  result->free();

  return resultString;
}

void ModuleManager::addModuleListener(ExecutionContext* context, QJSFunction* handler, ExceptionState* exception) {
  auto* listener = makeGarbageCollected<ModuleListener>(handler);
  context->moduleListeners()->addModuleListener(listener);
}

}  // namespace kraken
