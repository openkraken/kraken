/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_manager.h"
#include "bridge_qjs.h"
#include "foundation/bridge_callback.h"
#include "qjs_patch.h"

namespace kraken::binding::qjs {

using namespace kraken::foundation;

JSValue krakenModuleListener(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(
      ctx, "Failed to execute '__kraken_module_listener__': 1 parameter required, but only 0 present.");
  }

  JSValue &callbackValue = argv[0];
  if (!JS_IsObject(callbackValue)) {
    return JS_ThrowTypeError(
      ctx, "Failed to execute '__kraken_module_listener__': parameter 1 (callback) must be a function.");
  }

  if (!JS_IsFunction(ctx, callbackValue)) {
    return JS_ThrowTypeError(
      ctx, "Failed to execute '__kraken_module_listener__': parameter 1 (callback) must be a function.");
  }

  auto context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
  auto bridge = static_cast<JSBridge *>(context->getOwner());
  bridge->krakenModuleListenerList.push_back(callbackValue);
  return JS_NULL;
}

void handleInvokeModuleTransientCallback(void *callbackContext, int32_t contextId, NativeString *errmsg,
                                         NativeString *json) {
  auto *obj = static_cast<BridgeCallback::Context *>(callbackContext);
  JSContext &_context = obj->m_context;

  if (!checkContext(contextId, &_context)) return;
  if (!_context.isValid()) return;

  if (JS_IsNull(obj->m_callback)) {
    JSValue exception =
      JS_ThrowTypeError(_context.context(), "Failed to execute '__kraken_invoke_module__': callback is null.");
    _context.handleException(&exception);
    return;
  }

  QjsContext *ctx = obj->m_context.context();
  if (!JS_IsObject(obj->m_callback)) {
    return;
  }

  JSValue &callback = obj->m_callback;
  JSValue returnValue;
  if (errmsg != nullptr) {
    JSValue errorMessage = JS_NewUnicodeString(obj->m_context.runtime(), ctx, errmsg->string, errmsg->length);
    JSValue errorObject = JS_NewError(ctx);
    JS_DefinePropertyValue(ctx, errorObject, JS_NewAtom(ctx, "message"), errorMessage,
                           JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
    JSValue arguments[] = {errorObject};
    returnValue = JS_Call(ctx, callback, obj->m_context.global(), 1, arguments);
  } else {
    std::u16string argumentString = std::u16string(reinterpret_cast<const char16_t *>(json->string, json->length));
    std::string utf8Arguments = toUTF8(argumentString);
    JSValue jsonValue = JS_ParseJSON(ctx, utf8Arguments.c_str(), utf8Arguments.length(), "");
    JSValue arguments[] = {JS_NULL, jsonValue};
    returnValue = JS_Call(ctx, callback, obj->m_context.global(), 2, arguments);
  }

  _context.handleException(&returnValue);
  auto bridge = static_cast<JSBridge *>(obj->m_context.getOwner());
  bridge->bridgeCallback->freeBridgeCallbackContext(obj);
}

void handleInvokeModuleUnexpectedCallback(void *callbackContext, int32_t contextId, NativeString *errmsg,
                                          NativeString *json) {
  static_assert("Unexpected module callback, please check your invokeModule implementation on the dart side.");
}

JSValue krakenInvokeModule(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'kraken.invokeModule()': 2 arguments required.");
  }

  JSValue &moduleNameValue = argv[0];
  JSValue &methodValue = argv[1];
  JSValue paramsValue = JS_NULL;
  JSValue callbackValue = JS_NULL;

  if (argc > 2 && !JS_IsNull(argv[2])) {
    paramsValue = JS_JSONStringify(ctx, argv[2], JS_NULL, JS_NULL);
  }

  if (argc > 3 && JS_IsObject(argv[3])) {
    callbackValue = argv[3];
  }

  if (getDartMethod()->invokeModule == nullptr) {
    return JS_ThrowTypeError(
      ctx, "Failed to execute '__kraken_invoke_module__': dart method (invokeModule) is not registered.");
  }

  std::unique_ptr<BridgeCallback::Context> callbackContext = nullptr;
  auto context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));

  NativeString *moduleName = jsValueToNativeString(ctx, moduleNameValue);
  NativeString *method = jsValueToNativeString(ctx, methodValue);
  NativeString *params = JS_IsNull(paramsValue) ? nullptr : jsValueToNativeString(ctx, paramsValue);

  if (JS_IsNull(callbackValue)) {
    auto emptyFunction = [](QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) -> JSValue {
      return JS_NULL;
    };
    JSValue callbackFunc = JS_NewCFunction(ctx, emptyFunction, "_f", 0);
    callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackFunc);
  } else {
    callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackValue);
  }

  auto bridge = static_cast<JSBridge *>(context->getOwner());
  NativeString *result;

  if (!JS_IsNull(callbackValue)) {
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
    return JS_NULL;
  }

  JSValue resultString = JS_NewUnicodeString(context->runtime(), ctx, result->string, result->length);
  result->free();
  moduleName->free();
  method->free();
  if (params != nullptr) {
    params->free();
  }

  return resultString;
}

JSValue flushUICommand(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {

}

void bindModuleManager(std::unique_ptr<JSContext> &context) {
  QJS_GLOBAL_BINDING_FUNCTION(context, krakenModuleListener, "__kraken_module_listener__", 1);
  QJS_GLOBAL_BINDING_FUNCTION(context, krakenInvokeModule, "__kraken_invoke_module__", 3);
  QJS_GLOBAL_BINDING_FUNCTION(context, flushUICommand, "__kraken_flush_ui_command__", 0);
}

} // namespace kraken::binding::qjs
