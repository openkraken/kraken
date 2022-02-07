/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "timer.h"

namespace kraken {

static JSValue setTimeout(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue callbackValue = argv[0];
  JSValue timeoutValue = argv[1];

  if (!JS_IsObject(callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': parameter 1 (callback) must be a function.");
  }

  if (!JS_IsFunction(ctx, callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': parameter 1 (callback) must be a function.");
  }

  int32_t timeout;

  if (argc < 2 || JS_IsUndefined(timeoutValue)) {
    timeout = 0;
  } else if (JS_IsNumber(timeoutValue)) {
    JS_ToInt32(ctx, &timeout, timeoutValue);
  } else {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': parameter 2 (timeout) only can be a number or undefined.");
  }

#if FLUTTER_BACKEND
  if (getDartMethod()->setTimeout == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': dart method (setTimeout) is not registered.");
  }
#endif

  // Create a timer object to keep track timer callback.
  auto* timer = makeGarbageCollected<DOMTimer>(JS_DupValue(ctx, callbackValue))->initialize<DOMTimer>(context->ctx(), &DOMTimer::classId);

  auto timerId = context->dartMethodPtr()->setTimeout(timer, context->getContextId(), handleTransientCallback, timeout);

  // Register timerId.
  timer->setTimerId(timerId);

  context->timers()->installNewTimer(context, timerId, timer);

  // `-1` represents ffi error occurred.
  if (timerId == -1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': dart method (setTimeout) execute failed");
  }

  return JS_NewUint32(ctx, timerId);
}

static JSValue setInterval(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue callbackValue = argv[0];
  JSValue timeoutValue = argv[1];

  if (!JS_IsObject(callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': parameter 1 (callback) must be a function.");
  }

  if (!JS_IsFunction(ctx, callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': parameter 1 (callback) must be a function.");
  }

  int32_t timeout;

  if (argc < 2 || JS_IsUndefined(timeoutValue)) {
    timeout = 0;
  } else if (JS_IsNumber(timeoutValue)) {
    JS_ToInt32(ctx, &timeout, timeoutValue);
  } else {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': parameter 2 (timeout) only can be a number or undefined.");
  }

  if (context->dartMethodPtr()->setInterval == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': dart method (setInterval) is not registered.");
  }

  // Create a timer object to keep track timer callback.
  auto* timer = makeGarbageCollected<DOMTimer>(JS_DupValue(ctx, callbackValue))->initialize<DOMTimer>(context->ctx(), &DOMTimer::classId);

  uint32_t timerId = context->dartMethodPtr()->setInterval(timer, context->getContextId(), handlePersistentCallback, timeout);

  // Register timerId.
  timer->setTimerId(timerId);
  context->timers()->installNewTimer(context, timerId, timer);

  if (timerId == -1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': dart method (setInterval) got unexpected error.");
  }

  return JS_NewUint32(ctx, timerId);
}

static JSValue clearTimeout(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc <= 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'clearTimeout': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));

  JSValue timeIdValue = argv[0];
  if (!JS_IsNumber(timeIdValue)) {
    return JS_NULL;
  }

  int32_t id;
  JS_ToInt32(ctx, &id, timeIdValue);

  if (context->dartMethodPtr()->clearTimeout == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'clearTimeout': dart method (clearTimeout) is not registered.");
  }

  context->dartMethodPtr()->clearTimeout(context->getContextId(), id);

  context->timers()->removeTimeoutById(id);
  return JS_NULL;
}

void bindTimer(ExecutionContext* context) {
  //  QJS_GLOBAL_BINDING_FUNCTION(context, setTimeout, "setTimeout", 2);
  //  QJS_GLOBAL_BINDING_FUNCTION(context, setInterval, "setInterval", 2);
  //  QJS_GLOBAL_BINDING_FUNCTION(context, clearTimeout, "clearTimeout", 1);
  //  QJS_GLOBAL_BINDING_FUNCTION(context, clearTimeout, "clearInterval", 1);
}

}  // namespace kraken
