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

JSValueRef krakenUIManager(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount < 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute '__kraken_ui_manager__': 1 argument required, but only 0 present.",
                    exception);
    return nullptr;
  }

  const JSValueRef &messageValue = arguments[0];
  JSStringRef messageStr = JSValueToStringCopy(ctx, messageValue, exception);
  const uint16_t *unicodeString = JSStringGetCharactersPtr(messageStr);
  size_t unicodeLength = JSStringGetLength(messageStr);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[krakenUIManager]: " << JSStringToStdString(messageStr) << std::endl;
  }

  if (getDartMethod()->invokeUIManager == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to execute '__kraken_ui_manager__': dart method (invokeUIManager) is not registered.",
                    exception);
    return nullptr;
  }

  NativeString nativeString{};
  nativeString.string = unicodeString;
  nativeString.length = unicodeLength;

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));
  const NativeString *result = getDartMethod()->invokeUIManager(context->getContextId(), &nativeString);
  JSStringRef retValue = JSStringCreateWithCharacters(result->string, result->length);
  return JSValueMakeString(ctx, retValue);
}

JSValueRef krakenUIListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount < 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute '__kraken_ui_listener__': 1 parameter required, but only 0 present.",
                    exception);
    return nullptr;
  }

  const JSValueRef &callbackValue = arguments[0];
  if (!JSValueIsObject(ctx, callbackValue)) {
    JSC_THROW_ERROR(ctx, "Failed to execute '__kraken_ui_listener__': parameter 1 (callback) must be an function.",
                    exception);
    return nullptr;
  }

  JSObjectRef callbackObject = JSValueToObject(ctx, callbackValue, exception);
  if (!JSObjectIsFunction(ctx, callbackObject)) {
    JSC_THROW_ERROR(ctx, "Failed to execute '__kraken_ui_listener__': parameter 1 (callback) must be an function.",
                    exception);
    return nullptr;
  }

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));
  auto bridge = static_cast<JSBridge *>(context->getOwner());

  // Needs to protect this function been garbage collected by GC.
  JSValueProtect(ctx, callbackObject);
  bridge->krakenUIListenerList.push_back(callbackObject);
  return nullptr;
}

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

  JSObjectRef callback = JSValueToObject(ctx, obj->_callback, obj->exception);
  JSStringRef argumentsString = JSStringCreateWithCharacters(json->string, json->length);
  const JSValueRef arguments[] = {JSValueMakeString(ctx, argumentsString)};
  JSObjectCallAsFunction(ctx, callback, obj->_context.global(), 1, arguments, obj->exception);
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

  const auto *result = bridge->bridgeCallback->registerCallback<const NativeString *>(
    std::move(callbackContext), [&nativeString](BridgeCallback::Context *bridgeContext, int32_t contextId) {
      const NativeString *response =
        getDartMethod()->invokeModule(bridgeContext, contextId, &nativeString, handleInvokeModuleTransientCallback);
      return response;
    });

  if (result == nullptr) {
    return JSValueMakeNull(ctx);
  }

  JSStringRef resultString = JSStringCreateWithCharacters(result->string, result->length);
  return JSValueMakeString(ctx, resultString);
}

JSValueRef requestUpdateFrame(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef arguments[], JSValueRef *exception) {
  if (getDartMethod()->requestUpdateFrame == nullptr) {
    JSC_THROW_ERROR(
      ctx, "Failed to execute '__kraken_request_update_frame__': dart method (requestUpdateFrame) is not registered.",
      exception);
    return nullptr;
  }
  getDartMethod()->requestUpdateFrame();
  return nullptr;
}

void handleBatchUpdate(void *ptr, int32_t contextId, const char *errmsg) {
  auto callbackContext = static_cast<BridgeCallback::Context *>(ptr);
  JSContext &_context = callbackContext->_context;
  JSContextRef ctx = _context.context();

  if (!checkContext(contextId, &_context)) return;

  if (!_context.isValid()) return;

  if (callbackContext->_callback == nullptr) {
    _context.reportError("Failed to execute '__kraken_request_batch_update__': callback is null.");
    return;
  }

  if (!JSValueIsObject(ctx, callbackContext->_callback)) {
    return;
  }

  if (errmsg != nullptr) {
    _context.reportError(errmsg);
    return;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callbackContext->_callback, callbackContext->exception);
  JSObjectCallAsFunction(ctx, callbackObjectRef, _context.global(), 0, nullptr, callbackContext->exception);
}

JSValueRef requestBatchUpdate(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount <= 0) {
    JSC_THROW_ERROR(
      ctx, "Failed to execute '__kraken_request_batch_update__': 1 parameter required, but only 0 present.", exception);
    return nullptr;
  }

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));
  const JSValueRef &callbackValueRef = arguments[0];

  if (!JSValueIsObject(ctx, callbackValueRef)) {
    JSC_THROW_ERROR(ctx,
                    "Failed to execute '__kraken_request_batch_update__': parameter 1 (callback) must be an function.",
                    exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callbackValueRef, exception);

  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    JSC_THROW_ERROR(ctx,
                    "Failed to execute '__kraken_request_batch_update__': parameter 1 (callback) must be an function.",
                    exception);
    return nullptr;
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackObjectRef, exception);

  if (getDartMethod()->requestBatchUpdate == nullptr) {
    JSC_THROW_ERROR(
      ctx, "Failed to execute '__kraken_request_batch_update__': dart method (requestBatchUpdate) is not registered.",
      exception);
    return nullptr;
  }

  auto bridge = static_cast<JSBridge *>(context->getOwner());
  bridge->bridgeCallback->registerCallback<void>(
    std::move(callbackContext), [](BridgeCallback::Context *callbackContext, int32_t contextId) {
      getDartMethod()->requestBatchUpdate(callbackContext, contextId, handleBatchUpdate);
    });

  return nullptr;
}

void bindUIManager(std::unique_ptr<JSContext> &context) {
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_ui_manager__", krakenUIManager);
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_ui_listener__", krakenUIListener);
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_module_listener__", krakenModuleListener);
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_invoke_module__", krakenInvokeModule);
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_request_batch_update__", requestBatchUpdate);
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_request_update_frame__", requestUpdateFrame);
}

} // namespace kraken::binding::jsc
