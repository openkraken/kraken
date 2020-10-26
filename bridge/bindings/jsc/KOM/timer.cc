/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "timer.h"
#include "bindings/jsc/macros.h"
#include "bridge_jsc.h"
#include "dart_methods.h"
#include "foundation/bridge_callback.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

using namespace kraken::foundation;

void handlePersistentCallback(void *ptr, int32_t contextId, const char *errmsg) {
  auto *callbackContext = static_cast<BridgeCallback::Context *>(ptr);
  JSContext &_context = callbackContext->_context;
  if (!checkContext(contextId, &_context)) return;

  if (!_context.isValid()) return;

  if (callbackContext->_callback == nullptr) {
    // throw JSError inside of dart function callback will directly cause crash
    // so we handle it instead of throw
    JSC_THROW_ERROR(_context.context(), "Failed to trigger callback: timer callback is null.",
                    callbackContext->exception);
    return;
  }

  if (!JSValueIsObject(_context.context(), callbackContext->_callback)) {
    return;
  }

  if (errmsg != nullptr) {
    JSC_THROW_ERROR(_context.context(), errmsg, callbackContext->exception);
    return;
  }

  JSObjectRef callbackObjectRef =
    JSValueToObject(_context.context(), callbackContext->_callback, callbackContext->exception);
  JSObjectCallAsFunction(_context.context(), callbackObjectRef, _context.global(), 0, nullptr,
                         callbackContext->exception);
}

void handleRAFPersistentCallback(void *ptr, int32_t contextId, double result, const char *errmsg) {
  auto *callbackContext = static_cast<BridgeCallback::Context *>(ptr);
  JSContext &_context = callbackContext->_context;
  if (!checkContext(contextId, &_context)) return;

  if (!_context.isValid()) return;

  if (callbackContext->_callback == nullptr) {
    // throw JSError inside of dart function callback will directly cause crash
    // so we handle it instead of throw
    JSC_THROW_ERROR(_context.context(), "Failed to trigger callback: requestAnimationFrame callback is null.",
                    callbackContext->exception);
    return;
  }

  if (!JSValueIsObject(_context.context(), callbackContext->_callback)) {
    return;
  }

  if (errmsg != nullptr) {
    JSC_THROW_ERROR(_context.context(), errmsg, callbackContext->exception);
    return;
  }

  JSObjectRef callbackObjectRef =
    JSValueToObject(_context.context(), callbackContext->_callback, callbackContext->exception);
  JSObjectCallAsFunction(_context.context(), callbackObjectRef, _context.global(), 0, nullptr,
                         callbackContext->exception);
}

void handleTransientCallback(void *callbackContext, int32_t contextId, const char *errmsg) {
  handlePersistentCallback(callbackContext, contextId, errmsg);
}

void handleRAFTransientCallback(void *callbackContext, int32_t contextId, double result, const char *errmsg) {
  handleRAFPersistentCallback(callbackContext, contextId, result, errmsg);
}

JSValueRef setTimeout(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                      const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setTimeout': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));

  const JSValueRef &callbackValueRef = arguments[0];
  const JSValueRef &timeoutValueRef = arguments[1];

  if (!JSValueIsObject(ctx, callbackValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setTimeout': parameter 1 (callback) must be a function.", exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callbackValueRef, exception);

  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setTimeout': parameter 1 (callback) must be a function.", exception);
    return nullptr;
  }

  int32_t timeout;

  if (argumentCount < 2 || JSValueIsUndefined(ctx, timeoutValueRef)) {
    timeout = 0;
  } else if (JSValueIsNumber(ctx, timeoutValueRef)) {
    timeout = JSValueToNumber(ctx, timeoutValueRef, exception);
  } else {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setTimeout': parameter 2 (timeout) only can be a number or undefined.",
                    exception);
    return nullptr;
  }

  if (getDartMethod()->setTimeout == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setTimeout': dart method (setTimeout) is not registered.", exception);
    return nullptr;
  }

  auto callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackObjectRef, exception);
  auto bridge = static_cast<JSBridge *>(context->getOwner());
  auto timerId = bridge->bridgeCallback->registerCallback<int32_t>(
    std::move(callbackContext), [&timeout](BridgeCallback::Context *callbackContext, int32_t contextId) {
      return getDartMethod()->setTimeout(callbackContext, contextId, handleTransientCallback, timeout);
    });

  // `-1` represents ffi error occurred.
  if (timerId == -1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setTimeout': dart method (setTimeout) execute failed", exception);
    return nullptr;
  }

  return JSValueMakeNumber(ctx, timerId);
}

JSValueRef setInterval(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                       const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setInterval': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));

  const JSValueRef &callbackValueRef = arguments[0];
  const JSValueRef &timeoutValueRef = arguments[1];

  if (!JSValueIsObject(ctx, callbackValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setInterval': parameter 1 (callback) must be a function.", exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callbackValueRef, exception);

  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setInterval': parameter 1 (callback) must be a function.", exception);
    return nullptr;
  }

  int32_t timeout;

  if (argumentCount < 2 || JSValueIsUndefined(ctx, timeoutValueRef)) {
    timeout = 0;
  } else if (JSValueIsNumber(ctx, timeoutValueRef)) {
    timeout = JSValueToNumber(ctx, timeoutValueRef, exception);
  } else {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setTimeout': parameter 2 (timeout) only can be a number or undefined.",
                    exception);
    return nullptr;
  }

  if (getDartMethod()->setInterval == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setInterval': dart method (setInterval) is not registered.", exception);
    return nullptr;
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackObjectRef, exception);
  auto bridge = static_cast<JSBridge *>(context->getOwner());
  auto timerId = bridge->bridgeCallback->registerCallback<int32_t>(
    std::move(callbackContext), [&timeout](BridgeCallback::Context *callbackContext, int32_t contextId) {
      return getDartMethod()->setInterval(callbackContext, contextId, handlePersistentCallback, timeout);
    });

  if (timerId == -1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setInterval': dart method (setInterval) got unexpected error.", exception);
    return nullptr;
  }

  return JSValueMakeNumber(ctx, timerId);
}

JSValueRef clearTimeout(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                        const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount <= 0) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'clearTimeout': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));

  const JSValueRef timerIdValueRef = arguments[0];
  if (!JSValueIsNumber(ctx, timerIdValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'clearTimeout': parameter 1  is not an timer kind.", exception);
    return nullptr;
  }

  auto id = static_cast<int32_t>(JSValueToNumber(ctx, timerIdValueRef, exception));

  if (getDartMethod()->clearTimeout == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'clearTimeout': dart method (clearTimeout) is not registered.", exception);
    return nullptr;
  }

  getDartMethod()->clearTimeout(context->getContextId(), id);
  return nullptr;
}

JSValueRef cancelAnimationFrame(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount <= 0) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'cancelAnimationFrame': 1 argument required, but only 0 present.",
                    exception);
    return nullptr;
  }

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));

  const JSValueRef requestIdValueRef = arguments[0];
  if (!JSValueIsNumber(ctx, requestIdValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'cancelAnimationFrame': parameter 1 (timer) is not a timer kind.",
                    exception);
    return nullptr;
  }

  auto id = static_cast<int32_t>(JSValueToNumber(ctx, requestIdValueRef, exception));

  if (getDartMethod()->cancelAnimationFrame == nullptr) {
    JSC_THROW_ERROR(ctx,
                    "Failed to execute 'cancelAnimationFrame': dart method (cancelAnimationFrame) is not registered.",
                    exception);
    return nullptr;
  }

  getDartMethod()->cancelAnimationFrame(context->getContextId(), id);

  return nullptr;
}

JSValueRef requestAnimationFrame(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount <= 0) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'requestAnimationFrame': 1 argument required, but only 0 present.",
                    exception);
    return nullptr;
  }

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));
  const JSValueRef &callbackValueRef = arguments[0];

  if (!JSValueIsObject(ctx, callbackValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'requestAnimationFrame': parameter 1 (callback) must be a function.",
                    exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callbackValueRef, exception);

  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'requestAnimationFrame': parameter 1 (callback) must be a function.",
                    exception);
    return nullptr;
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackObjectRef, exception);

  if (getDartMethod()->requestAnimationFrame == nullptr) {
    JSC_THROW_ERROR(ctx,
                    "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) is not registered.",
                    exception);
    return nullptr;
  }

  auto bridge = static_cast<JSBridge *>(context->getOwner());
  int32_t requestId = bridge->bridgeCallback->registerCallback<int32_t>(
    std::move(callbackContext), [](BridgeCallback::Context *callbackContext, int32_t contextId) {
      return getDartMethod()->requestAnimationFrame(callbackContext, contextId, handleRAFTransientCallback);
    });

  // `-1` represents some error occurred.
  if (requestId == -1) {
    JSC_THROW_ERROR(ctx,
                    "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) executed "
                    "with unexpected error.",
                    exception);
    return nullptr;
  }

  return JSValueMakeNumber(ctx, requestId);
}

JSValueRef reloadApp(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                  const JSValueRef *arguments, JSValueRef *exception) {
  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));
  getDartMethod()->reloadApp(context->getContextId());
  return nullptr;
}

void bindTimer(std::unique_ptr<JSContext> &context) {
  JSC_GLOBAL_BINDING_FUNCTION(context, "setTimeout", setTimeout);
  JSC_GLOBAL_BINDING_FUNCTION(context, "setInterval", setInterval);
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_request_animation_frame__", requestAnimationFrame);
  JSC_GLOBAL_BINDING_FUNCTION(context, "clearTimeout", clearTimeout);
  JSC_GLOBAL_BINDING_FUNCTION(context, "clearInternal", clearTimeout);
  JSC_GLOBAL_BINDING_FUNCTION(context, "reload", reloadApp);
  JSC_GLOBAL_BINDING_FUNCTION(context, "cancelAnimationFrame", cancelAnimationFrame);
}

} // namespace kraken::binding::jsc
