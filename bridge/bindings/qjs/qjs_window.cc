/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_window.h"
#include <quickjs/quickjs.h>
#include "core/executing_context.h"
#include "core/frame/window_or_worker_global_scope.h"
#include "exception_state.h"
#include "member_installer.h"
#include "qjs_function.h"

namespace kraken {

static JSValue setTimeout(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTimeout': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
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

  auto handler = QJSFunction::Create(ctx, callbackValue);
  ExceptionState exceptionState;

  int32_t timerId = WindowOrWorkerGlobalScope::setTimeout(context, handler, timeout, &exceptionState);

  if (exceptionState.HasException()) {
    return exceptionState.ToQuickJS();
  }

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

  auto context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
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

  auto handler = QJSFunction::Create(ctx, callbackValue);
  ExceptionState exception;
  int32_t timerId = WindowOrWorkerGlobalScope::setInterval(context, handler, timeout, &exception);

  if (exception.HasException()) {
    return exception.ToQuickJS();
  }

  if (timerId == -1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setInterval': dart method (setInterval) got unexpected error.");
  }

  return JS_NewUint32(ctx, timerId);
}

static JSValue clearTimeout(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc <= 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'clearTimeout': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));

  JSValue timeIdValue = argv[0];
  if (!JS_IsNumber(timeIdValue)) {
    return JS_NULL;
  }

  int32_t id;
  JS_ToInt32(ctx, &id, timeIdValue);

  ExceptionState exception;
  WindowOrWorkerGlobalScope::clearTimeout(context, id, &exception);

  if (exception.HasException()) {
    return exception.ToQuickJS();
  }

  return JS_NULL;
}

void QJSWindow::installGlobalFunctions(ExecutingContext* context) {
  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig{
      {"setTimeout", setTimeout, 2},
      {"setInterval", setInterval, 2},
      {"clearTimeout", clearTimeout, 0},
  };

  MemberInstaller::InstallFunctions(context, context->Global(), functionConfig);
}

}  // namespace kraken
