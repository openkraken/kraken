/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_module_manager.h"
#include "member_installer.h"
#include "qjs_function.h"
#include "core/frame/module_manager.h"

namespace kraken {


JSValue krakenModuleListener(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_module_listener__': 1 parameter required, but only 0 present.");
  }

  JSValue callbackValue = argv[0];
  if (!JS_IsObject(callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_module_listener__': parameter 1 (callback) must be a function.");
  }

  if (!JS_IsFunction(ctx, callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_module_listener__': parameter 1 (callback) must be a function.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));

  QJSFunction* handler = QJSFunction::create(ctx, callbackValue);
  ExceptionState exception;

  ModuleManager::addModuleListener(context, handler, &exception);
  if (exception.hasException()) {
    return exception.toQuickJS();
  }

//  auto* link = new ModuleContext{JS_DupValue(ctx, callbackValue), context};
//  list_add_tail(&link->link, &context->module_job_list);

  return JS_NULL;
}

JSValue krakenInvokeModule(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'kraken.invokeModule()': 2 arguments required.");
  }

  ScriptValue moduleName = ScriptValue(ctx, argv[0]);
  ScriptValue methodValue = ScriptValue(ctx, argv[1]);
  ScriptValue paramsValue = ScriptValue(ctx, JS_NULL);

  QJSFunction* callback = nullptr;

  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));

  if (argc > 2 && !JS_IsNull(argv[2])) {
    paramsValue = ScriptValue(ctx, argv[2]);
  }

  if (argc > 3 && JS_IsFunction(ctx, argv[3])) {
    callback = QJSFunction::create(ctx, argv[3]);
  }

  ExceptionState exception;
  ScriptValue result = ModuleManager::invokeModule(context, moduleName, methodValue, paramsValue, callback, &exception);

  if (exception.hasException()) {
    return exception.toQuickJS();
  }

  return result.toQuickJS();
}

JSValue flushUICommand(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));

  if (context->dartMethodPtr()->flushUICommand == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_flush_ui_command__': dart method (flushUICommand) is not registered.");
  }
  context->dartMethodPtr()->flushUICommand();
  return JS_NULL;
}

void QJSModuleManager::installGlobalFunctions(JSContext* ctx) {
  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
    {"__kraken_module_listener__", krakenModuleListener, 1, combinePropFlags(JSPropFlag::enumerable, JSPropFlag::writable, JSPropFlag::configurable)},
    {"__kraken_invoke_module__", krakenInvokeModule, 3, combinePropFlags(JSPropFlag::enumerable, JSPropFlag::writable, JSPropFlag::configurable)},
    {"__kraken_flush_ui_command__", flushUICommand, 0, combinePropFlags(JSPropFlag::enumerable, JSPropFlag::writable, JSPropFlag::configurable)},
  };

  JSValue globalObject = JS_GetGlobalObject(ctx);
  MemberInstaller::installFunctions(ctx, globalObject, functionConfig);
  JS_FreeValue(ctx, globalObject);
}

}
