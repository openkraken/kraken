/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "timer.h"
#include "bindings/jsc/macros.h"
#include "bridge.h"
#include "dart_methods.h"
#include "foundation/bridge_callback.h"

namespace kraken::binding::jsc {

using namespace kraken::foundation;

void handlePersistentCallback(void *callbackContext, int32_t contextId, const char *errmsg) {
  auto *obj = static_cast<BridgeCallback::Context *>(callbackContext);
  JSContext &_context = obj->_context;
  if (!checkContext(contextId, &_context)) return;

  if (!_context.isValid()) return;

  if (obj->_callback == nullptr) {
    // throw JSError inside of dart function callback will directly cause crash
    // so we handle it instead of throw
    _context.reportError("Failed to trigger callback: timer callback is null.");
    return;
  }

  if (!JSValueIsObject(_context.context(), obj->_callback)) {
    return;
  }

  if (errmsg != nullptr) {
    obj->_context.reportError(errmsg);
    return;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(_context.context(), obj->_callback, nullptr);
  JSObjectCallAsFunction(_context.context(), callbackObjectRef, _context.global(), 0, nullptr, nullptr);
}

void handleRAFPersistentCallback(void *callbackContext, int32_t contextId, double result, const char *errmsg) {
  auto *obj = static_cast<BridgeCallback::Context *>(callbackContext);
  JSContext &_context = obj->_context;
  if (!checkContext(contextId, &_context)) return;

  if (!_context.isValid()) return;

  if (obj->_callback == nullptr) {
    // throw JSError inside of dart function callback will directly cause crash
    // so we handle it instead of throw
    _context.reportError("Failed to trigger callback: requestAnimationFrame callback is null.");
    return;
  }

  if (!JSValueIsObject(_context.context(), obj->_callback)) {
    return;
  }

  if (errmsg != nullptr) {
    obj->_context.reportError(errmsg);
    return;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(_context.context(), obj->_callback, nullptr);
  JSObjectCallAsFunction(_context.context(), callbackObjectRef, _context.global(), 0, nullptr, nullptr);
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

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(thisObject));

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

  if (JSValueIsUndefined(ctx, timeoutValueRef) || argumentCount < 2) {
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
  auto timerId = bridge->bridgeCallback.registerCallback<int32_t>(
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

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(thisObject));

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

  if (JSValueIsUndefined(ctx, timeoutValueRef) || argumentCount < 2) {
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
  auto timerId = bridge->bridgeCallback.registerCallback<int32_t>(
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

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(thisObject));

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

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(thisObject));

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
    JSC_THROW_ERROR(ctx, "Failed to execute 'requestAnimationFrame': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(thisObject));
  const JSValueRef &callbackValueRef = arguments[0];

  if (!JSValueIsObject(ctx, callbackValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'requestAnimationFrame': parameter 1 (callback) must be a function.", exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callbackValueRef, exception);

  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'requestAnimationFrame': parameter 1 (callback) must be a function.", exception);
    return nullptr;
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackObjectRef, exception);

  if (getDartMethod()->requestAnimationFrame == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) is not registered.", exception);
    return nullptr;
  }

  auto bridge = static_cast<JSBridge *>(context->getOwner());
  int32_t requestId = bridge->bridgeCallback.registerCallback<int32_t>(
    std::move(callbackContext), [](BridgeCallback::Context *callbackContext, int32_t contextId) {
      return getDartMethod()->requestAnimationFrame(callbackContext, contextId, handleRAFTransientCallback);
    });

  // `-1` represents some error occurred.
  if (requestId == -1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) executed "
                         "with unexpected error.", exception);
    return nullptr;
  }

  return JSValueMakeNumber(ctx, requestId);
}

void bindTimer(std::unique_ptr<JSContext> &context) {
  JSC_GLOBAL_BINDING_FUNCTION(context, "setTimeout", setTimeout);
  JSC_GLOBAL_BINDING_FUNCTION(context, "setInterval", setInterval);
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_request_animation_frame__", requestAnimationFrame);
  JSC_GLOBAL_BINDING_FUNCTION(context, "clearTimeout", clearTimeout);
  JSC_GLOBAL_BINDING_FUNCTION(context, "clearInternal", clearTimeout);
  JSC_GLOBAL_BINDING_FUNCTION(context, "cancelAnimationFrame", cancelAnimationFrame);
}

} // namespace kraken::binding::jsc
