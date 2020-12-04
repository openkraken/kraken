/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "ui_manager.h"
#include "bindings/jsc/macros.h"
#include "bridge_jsc.h"
#include "dart_methods.h"
#include "foundation/bridge_callback.h"
#include "foundation/logging.h"

namespace kraken::binding::jsc {
using namespace foundation;

JSValueRef krakenModuleListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount < 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute '__kraken_module_listener__': 1 parameter required, but only 0 present.",
                    exception);
    return nullptr;
  }

  const JSValueRef &callbackValue = arguments[0];
  if (!JSValueIsObject(ctx, callbackValue)) {
    JSC_THROW_ERROR(ctx, "Failed to execute '__kraken_module_listener__': parameter 1 (callback) must be a function.",
                    exception);
    return nullptr;
  }

  JSObjectRef callbackObject = JSValueToObject(ctx, callbackValue, exception);
  if (!JSObjectIsFunction(ctx, callbackObject)) {
    JSC_THROW_ERROR(ctx, "Failed to execute '__kraken_module_listener__': parameter 1 (callback) must be a function.",
                    exception);
    return nullptr;
  }

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));
  auto bridge = static_cast<JSBridge *>(context->getOwner());

  JSValueProtect(ctx, callbackObject);
  bridge->krakenModuleListenerList.push_back(callbackObject);

  return nullptr;
}

void handleInvokeModuleTransientCallback(void *callbackContext, int32_t contextId, NativeString *json) {
  auto *obj = static_cast<BridgeCallback::Context *>(callbackContext);
  JSContext &_context = obj->_context;

  if (!checkContext(contextId, &_context)) return;

  if (!_context.isValid()) return;

  JSValueRef exception = nullptr;

  if (obj->_callback == nullptr) {
    JSC_THROW_ERROR(_context.context(), "Failed to execute '__kraken_invoke_module__': callback is null.", &exception);
    _context.handleException(exception);
    return;
  }

  JSContextRef ctx = obj->_context.context();
  if (!JSValueIsObject(ctx, obj->_callback)) {
    return;
  }

  JSObjectRef callback = JSValueToObject(ctx, obj->_callback, &exception);
  JSStringRef argumentsString = JSStringCreateWithCharacters(json->string, json->length);
  const JSValueRef arguments[] = {JSValueMakeString(ctx, argumentsString)};
  JSObjectCallAsFunction(ctx, callback, obj->_context.global(), 1, arguments, &exception);
  _context.handleException(exception);

  auto bridge = static_cast<JSBridge *>(obj->_context.getOwner());
  bridge->bridgeCallback->freeBridgeCallbackContext(obj);
}

void handleInvokeModuleUnexpectedCallback(void *callbackContext, int32_t contextId, NativeString *json) {
  static_assert("Unexpected module callback, please check your invokeModule implementation on the dart side.");
}

JSValueRef krakenInvokeModule(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef arguments[], JSValueRef *exception) {
  const JSValueRef &messageValue = arguments[0];
  JSStringRef messageStr = JSValueToStringCopy(ctx, messageValue, exception);
  const uint16_t *unicodeStrPtr = JSStringGetCharactersPtr(messageStr);
  size_t unicodeLength = JSStringGetLength(messageStr);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[invokeModule]: " << JSStringToStdString(messageStr) << std::endl;
  }

  if (getDartMethod()->invokeModule == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to execute '__kraken_invoke_module__': dart method (invokeModule) is not registered.",
                    exception);
    return nullptr;
  }

  std::unique_ptr<BridgeCallback::Context> callbackContext = nullptr;
  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));

  if (argumentCount < 2) {
    JSObjectCallAsFunctionCallback emptyCallback = [](JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                      size_t argumentCount, const JSValueRef arguments[],
                                                      JSValueRef *exception) -> JSValueRef { return nullptr; };
    JSObjectRef callbackValue =
      JSObjectMakeFunctionWithCallback(ctx, JSStringCreateWithUTF8CString("f"), emptyCallback);
    callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackValue, exception);
  } else if (argumentCount == 2) {
    const JSValueRef callbackValue = arguments[1];
    JSObjectRef callbackObject = JSValueToObject(ctx, callbackValue, nullptr);
    callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackObject, exception);
  }

  auto bridge = static_cast<JSBridge *>(context->getOwner());

  NativeString nativeString{};
  nativeString.string = unicodeStrPtr;
  nativeString.length = unicodeLength;

  bool hasCallback = argumentCount == 2;

  const NativeString *result;
  if (hasCallback) {
    result = bridge->bridgeCallback->registerCallback<const NativeString *>(
      std::move(callbackContext), [&nativeString](BridgeCallback::Context *bridgeContext, int32_t contextId) {
        const NativeString *response =
          getDartMethod()->invokeModule(bridgeContext, contextId, &nativeString, handleInvokeModuleTransientCallback);
        return response;
      });
  } else {
    result = getDartMethod()->invokeModule(callbackContext.get(), context->getContextId(), &nativeString,
                                           handleInvokeModuleUnexpectedCallback);
  }

  if (result == nullptr) {
    return JSValueMakeNull(ctx);
  }

  JSStringRef resultString = JSStringCreateWithCharacters(result->string, result->length);

  delete[] result->string;
  delete result;

  return JSValueMakeString(ctx, resultString);
}

JSValueRef flushUICommand(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                          JSValueRef const *arguments, JSValueRef *exception) {
  if (getDartMethod()->flushUICommand == nullptr) {
    JSC_THROW_ERROR(
      ctx, "Failed to execute '__kraken_flush_ui_command__': dart method (flushUICommand) is not registered.",
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
