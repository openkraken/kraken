/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H
#define KRAKENBRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H

#include "core/executing_context.h"
#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/exception_state.h"

namespace kraken {

class WindowOrWorkerGlobalScope {
 public:
  static int setTimeout(ExecutionContext* context, QJSFunction* handler, int32_t timeout, ExceptionState* exception);
  static int setInterval(ExecutionContext* context, QJSFunction* handler, int32_t timeout, ExceptionState* exception);
  static void clearTimeout(ExecutionContext* context, int32_t timerId, ExceptionState* exception);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H
