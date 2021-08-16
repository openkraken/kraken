/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "ui_manager.h"
#include "bridge_jsc.h"
#include "dart_methods.h"
#include "foundation/bridge_callback.h"

namespace kraken::binding::jsc {
using namespace foundation;

JSValueRef krakenModuleListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to execute '__kraken_module_listener__': 1 parameter required, but only 0 present.",
                 exception);
    return nullptr;
  }

  const JSValueRef &callbackValue = arguments[0];
  if (!JSValueIsObject(ctx, callbackValue)) {
    throwJSError(ctx, "Failed to execute '__kraken_module_listener__': parameter 1 (callback) must be a function.",
                 exception);
    return nullptr;
  }

  JSObjectRef callbackObject = JSValueToObject(ctx, callbackValue, exception);
  if (!JSObjectIsFunction(ctx, callbackObject)) {
    throwJSError(ctx, "Failed to execute '__kraken_module_listener__': parameter 1 (callback) must be a function.",
                 exception);
    return nullptr;
  }

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));
  auto bridge = static_cast<JSBridge *>(context->getOwner());

  JSValueProtect(ctx, callbackObject);
  bridge->krakenModuleListenerList.push_back(callbackObject);

  return nullptr;
}

void handleInvokeModuleTransientCallback(void *callbackContext, int32_t contextId, NativeString *errmsg,
                                         NativeString *json) {
  auto *obj = static_cast<BridgeCallback::Context *>(callbackContext);
  JSContext &_context = obj->_context;

  if (!checkContext(contextId, &_context)) return;

  if (!_context.isValid()) return;

  JSValueRef exception = nullptr;

  if (obj->_callback == nullptr) {
    throwJSError(_context.context(), "Failed to execute '__kraken_invoke_module__': callback is null.", &exception);
    _context.handleException(exception);
    return;
  }

  JSContextRef ctx = obj->_context.context();
  if (!JSValueIsObject(ctx, obj->_callback)) {
    return;
  }

  JSObjectRef callback = JSValueToObject(ctx, obj->_callback, &exception);

  if (errmsg != nullptr) {
    if (!obj->_context.isValid()) {
      return;
    }
    JSStringRef errorMsgStringRef = JSStringCreateWithCharacters(errmsg->string, errmsg->length);
    JSValueRef errArgs[] = {JSValueMakeString(ctx, errorMsgStringRef)};
    JSObjectRef errObject = JSObjectMakeError(ctx, 1, errArgs, &exception);
    const JSValueRef arguments[] = {errObject};
    JSObjectCallAsFunction(ctx, callback, obj->_context.global(), 1, arguments, &exception);
  } else {
    JSStringRef argumentsString = JSStringCreateWithCharacters(json->string, json->length);
    JSValueRef jsonValue = JSValueMakeFromJSONString(ctx, argumentsString);

    const JSValueRef arguments[] = {JSValueMakeNull(ctx), jsonValue};

    JSObjectCallAsFunction(ctx, callback, obj->_context.global(), 2, arguments, &exception);
  }

  _context.handleException(exception);

  auto bridge = static_cast<JSBridge *>(obj->_context.getOwner());
  bridge->bridgeCallback->freeBridgeCallbackContext(obj);
}

void handleInvokeModuleUnexpectedCallback(void *callbackContext, int32_t contextId, NativeString *errmsg,
                                          NativeString *json) {
  static_assert("Unexpected module callback, please check your invokeModule implementation on the dart side.");
}

JSValueRef krakenInvokeModule(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount < 2) {
    throwJSError(ctx, "Failed to execute 'kraken.invokeModule()': 2 arguments required.", exception);
    return nullptr;
  }

  JSStringRef moduleNameStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  JSStringRef methodStringRef = JSValueToStringCopy(ctx, arguments[1], exception);
  JSStringRef paramsStringRef = nullptr;
  JSValueRef callbackValueRef = nullptr;

  if (argumentCount > 2 && !JSValueIsNull(ctx, arguments[2])) {
    paramsStringRef = JSValueCreateJSONString(ctx, arguments[2], 0, exception);
  }

  if (argumentCount > 3 && JSValueIsObject(ctx, arguments[3])) {
    callbackValueRef = JSValueToObject(ctx, arguments[3], exception);
  }

  if (getDartMethod()->invokeModule == nullptr) {
    throwJSError(ctx, "Failed to execute '__kraken_invoke_module__': dart method (invokeModule) is not registered.",
                 exception);
    return nullptr;
  }

  std::unique_ptr<BridgeCallback::Context> callbackContext = nullptr;
  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));

  NativeString *moduleName = stringRefToNativeString(moduleNameStringRef);
  NativeString *method = stringRefToNativeString(methodStringRef);
  NativeString *params = paramsStringRef == nullptr ? nullptr : stringRefToNativeString(paramsStringRef);

  if (callbackValueRef == nullptr) {
    JSObjectCallAsFunctionCallback emptyCallback = [](JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                      size_t argumentCount, const JSValueRef arguments[],
                                                      JSValueRef *exception) -> JSValueRef { return nullptr; };
    JSObjectRef callbackValue =
      JSObjectMakeFunctionWithCallback(ctx, JSStringCreateWithUTF8CString("f"), emptyCallback);
    callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackValue, exception);
  } else {
    callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackValueRef, exception);
  }

  auto bridge = static_cast<JSBridge *>(context->getOwner());
  NativeString *result;
  if (callbackValueRef != nullptr) {
    result = bridge->bridgeCallback->registerCallback<NativeString *>(
      std::move(callbackContext),
      [moduleName, method, params](BridgeCallback::Context *bridgeContext, int32_t contextId) {
        NativeString *response = getDartMethod()->invokeModule(bridgeContext, contextId, moduleName, method, params,
                                                               handleInvokeModuleTransientCallback);
        return response;
      });
  } else {
    result = getDartMethod()->invokeModule(callbackContext.get(), context->getContextId(), moduleName, method, params,
                                           handleInvokeModuleUnexpectedCallback);
  }

  if (result == nullptr) {
    return JSValueMakeNull(ctx);
  }

  JSStringRef resultString = JSStringCreateWithCharacters(result->string, result->length);

  result->free();
  moduleName->free();
  method->free();
  if (params != nullptr) {
    params->free();
  }

  return JSValueMakeString(ctx, resultString);
}

JSValueRef flushUICommand(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                          JSValueRef const *arguments, JSValueRef *exception) {
  if (getDartMethod()->flushUICommand == nullptr) {
    throwJSError(ctx,
                 "Failed to execute '__kraken_flush_ui_command__': dart method (flushUICommand) is not registered.",
                 exception);
    return nullptr;
  }
  getDartMethod()->flushUICommand();
  return nullptr;
}

void bindUIManager(std::unique_ptr<JSContext> &context) {
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_module_listener__", krakenModuleListener);
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_invoke_module__", krakenInvokeModule);
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_flush_ui_command__", flushUICommand);
}

} // namespace kraken::binding::jsc
