/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "timer.h"
#include "bridge_callback.h"
#include "bridge_qjs.h"
#include "dart_methods.h"

namespace kraken::binding::qjs {

static void handleTimerCallback(kraken::foundation::BridgeCallback::Context *callbackContext, const char *errmsg) {
  auto &_context = callbackContext->m_context;
  if (JS_IsNull(callbackContext->m_callback)) {
    // throw JSError inside of dart function callback will directly cause crash
    // so we handle it instead of throw
    JSValue exception = JS_ThrowTypeError(_context.ctx(), "Failed to trigger callback: timer callback is null.");
    _context.handleException(&exception);
    return;
  }

  if (!JS_IsObject(callbackContext->m_callback)) {
    return;
  }

  if (errmsg != nullptr) {
    JSValue exception = JS_ThrowTypeError(_context.ctx(), "%s", errmsg);
    _context.handleException(&exception);
    return;
  }

  JSValue returnValue = JS_Call(_context.ctx(), callbackContext->m_callback, _context.global(), 0, nullptr);
  _context.handleException(&returnValue);
}

static void handleTransientCallback(void *ptr, int32_t contextId, const char *errmsg) {
  auto *callbackContext = static_cast<kraken::foundation::BridgeCallback::Context *>(ptr);
  JSContext &_context = callbackContext->m_context;
  if (!checkContext(contextId, &_context)) return;

  handleTimerCallback(callbackContext, errmsg);

  auto bridge = static_cast<JSBridge *>(callbackContext->m_context.getOwner());
  bridge->bridgeCallback->freeBridgeCallbackContext(callbackContext);
}

static void handlePersistentCallback(void *ptr, int32_t contextId, const char *errmsg) {
  auto *callbackContext = static_cast<kraken::foundation::BridgeCallback::Context *>(ptr);
  JSContext &_context = callbackContext->m_context;
  if (!checkContext(contextId, &_context)) return;

  if (!_context.isValid()) return;

  handleTimerCallback(callbackContext, errmsg);
}

static JSValue setTimeout(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
  JSValue &callbackValue = argv[0];
  JSValue &timeoutValue = argv[1];

  if (!JS_IsObject(callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': parameter 1 (callback) must be a function.");
  }

  if (!JS_IsFunction(ctx, callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': parameter 1 (callback) must be a function.");
  }

  uint32_t timeout;

  if (argc < 2 || JS_IsUndefined(timeoutValue)) {
    timeout = 0;
  } else if (JS_IsNumber(timeoutValue)) {
    JS_ToUint32(ctx, &timeout, timeoutValue);
  } else {
    return JS_ThrowTypeError(
      ctx, "Failed to execute 'setTimeout': parameter 2 (timeout) only can be a number or undefined.");
  }

  if (getDartMethod()->setTimeout == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': dart method (setTimeout) is not registered.");
  }

  auto callbackContext = std::make_unique<kraken::foundation::BridgeCallback::Context>(*context, callbackValue);
  auto bridge = static_cast<JSBridge *>(context->getOwner());
  auto timerId = bridge->bridgeCallback->registerCallback<int32_t>(
    std::move(callbackContext),
    [&timeout](kraken::foundation::BridgeCallback::Context *callbackContext, int32_t contextId) {
      return getDartMethod()->setTimeout(callbackContext, contextId, handleTransientCallback, timeout);
    });

  // `-1` represents ffi error occurred.
  if (timerId == -1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': dart method (setTimeout) execute failed");
  }

  return JS_NewUint32(ctx, timerId);
}

static void handleRAFTransientCallback(void *ptr, int32_t contextId, double highResTimeStamp, const char *errmsg) {
  auto *callbackContext = static_cast<kraken::foundation::BridgeCallback::Context *>(ptr);
  JSContext &_context = callbackContext->m_context;
  if (!checkContext(contextId, &_context)) return;

  if (!_context.isValid()) return;

  if (JS_IsNull(callbackContext->m_callback)) {
    // throw JSError inside of dart function callback will directly cause crash
    // so we handle it instead of throw
    JSValue exception = JS_ThrowTypeError(_context.ctx(), "Failed to trigger callback: requestAnimationFrame callback is null.");
    _context.handleException(&exception);
    return;
  }

  if (!JS_IsObject(callbackContext->m_callback)) {
    return;
  }

  if (errmsg != nullptr) {
    JSValue exception = JS_ThrowTypeError(_context.ctx(), "%s", errmsg);
    _context.handleException(&exception);
    return;
  }

  JSValue arguments[] = {
    JS_NewFloat64(_context.ctx(), highResTimeStamp)
  };

  JSValue returnValue = JS_Call(_context.ctx(), callbackContext->m_callback, _context.global(), 1, arguments);
  _context.handleException(&returnValue);
  auto bridge = static_cast<JSBridge *>(callbackContext->m_context.getOwner());
  bridge->bridgeCallback->freeBridgeCallbackContext(callbackContext);
}

static JSValue setInterval(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
  JSValue &callbackValue = argv[0];
  JSValue &timeoutValue = argv[1];

  if (!JS_IsObject(callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': parameter 1 (callback) must be a function.");
  }

  if (!JS_IsFunction(ctx, callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': parameter 1 (callback) must be a function.");
  }

  uint32_t timeout;

  if (argc < 2 || JS_IsUndefined(timeoutValue)) {
    timeout = 0;
  } else if (JS_IsNumber(timeoutValue)) {
    JS_ToUint32(ctx, &timeout, timeoutValue);
  } else {
    return JS_ThrowTypeError(
      ctx, "Failed to execute 'setTimeout': parameter 2 (timeout) only can be a number or undefined.");
  }
  if (getDartMethod()->setInterval == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': dart method (setInterval) is not registered.");
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto callbackContext = std::make_unique<kraken::foundation::BridgeCallback::Context>(*context, callbackValue);
  auto bridge = static_cast<JSBridge *>(context->getOwner());
  auto timerId = bridge->bridgeCallback->registerCallback<int32_t>(
    std::move(callbackContext),
    [&timeout](kraken::foundation::BridgeCallback::Context *callbackContext, int32_t contextId) {
      return getDartMethod()->setInterval(callbackContext, contextId, handlePersistentCallback, timeout);
    });

  if (timerId == -1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': dart method (setInterval) got unexpected error.");
  }

  return JS_NewUint32(ctx, timerId);
}

static JSValue requestAnimationFrame(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
  if (argc <= 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'requestAnimationFrame': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
  JSValue &callbackValue = argv[0];

  if (!JS_IsObject(callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'requestAnimationFrame': parameter 1 (callback) must be a function.");
  }


  if (!JS_IsFunction(ctx, callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'requestAnimationFrame': parameter 1 (callback) must be a function.");
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto callbackContext = std::make_unique<kraken::foundation::BridgeCallback::Context>(*context, callbackValue);

  if (getDartMethod()->flushUICommand == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_flush_ui_command__': dart method (flushUICommand) is not registered.");
  }
  // Flush all pending ui messages.
  getDartMethod()->flushUICommand();

  if (getDartMethod()->requestAnimationFrame == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) is not registered.");
  }

  auto bridge = static_cast<JSBridge *>(context->getOwner());
  uint32_t requestId = bridge->bridgeCallback->registerCallback<int32_t>(
      std::move(callbackContext), [](kraken::foundation::BridgeCallback::Context *callbackContext, int32_t contextId) {
        return getDartMethod()->requestAnimationFrame(callbackContext, contextId, handleRAFTransientCallback);
      });

  // `-1` represents some error occurred.
  if (requestId == -1) {
    return JS_ThrowTypeError(ctx,
                 "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) executed "
                 "with unexpected error.");
  }

  return JS_NewUint32(ctx, requestId);
}

static JSValue clearTimeout(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
  if (argc <= 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'clearTimeout': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));

  JSValue &timeIdValue = argv[0];
  if (!JS_IsNumber(timeIdValue)) {
    return JS_NULL;
  }

  uint32_t id;
  JS_ToUint32(ctx, &id, timeIdValue);

  if (getDartMethod()->clearTimeout == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'clearTimeout': dart method (clearTimeout) is not registered.");
  }

  getDartMethod()->clearTimeout(context->getContextId(), id);
  return JS_NULL;
}

static JSValue cancelAnimationFrame(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
  if (argc <= 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'cancelAnimationFrame': 1 argument required, but only 0 present.");
  }
  auto context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
  JSValue &requestIdValue = argv[0];
  if (!JS_IsNumber(requestIdValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'cancelAnimationFrame': parameter 1 (timer) is not a timer kind.");
  }

  uint32_t id;
  JS_ToUint32(ctx, &id, requestIdValue);

  if (getDartMethod()->cancelAnimationFrame == nullptr) {
    return JS_ThrowTypeError(
      ctx, "Failed to execute 'cancelAnimationFrame': dart method (cancelAnimationFrame) is not registered.");
  }
  getDartMethod()->cancelAnimationFrame(context->getContextId(), id);

  return JS_NULL;
}

void bindTimer(std::unique_ptr<JSContext> &context) {
  QJS_GLOBAL_BINDING_FUNCTION(context, setTimeout, "setTimeout", 2);
  QJS_GLOBAL_BINDING_FUNCTION(context, setInterval, "setInterval", 2);
  QJS_GLOBAL_BINDING_FUNCTION(context, requestAnimationFrame, "requestAnimationFrame", 1);
  QJS_GLOBAL_BINDING_FUNCTION(context, clearTimeout, "clearTimeout", 1);
  QJS_GLOBAL_BINDING_FUNCTION(context, clearTimeout, "clearInterval", 1);
  QJS_GLOBAL_BINDING_FUNCTION(context, cancelAnimationFrame, "cancelAnimationFrame", 1);
}
} // namespace kraken::binding::qjs
