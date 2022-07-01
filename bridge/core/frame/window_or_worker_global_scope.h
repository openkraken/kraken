/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H
#define KRAKENBRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/qjs_function.h"
#include "core/executing_context.h"

namespace kraken {

class WindowOrWorkerGlobalScope {
 public:
  static int setTimeout(ExecutingContext* context,
                        std::shared_ptr<QJSFunction> handler,
                        int32_t timeout,
                        ExceptionState& exception);
  static int setTimeout(ExecutingContext* context, std::shared_ptr<QJSFunction> handler, ExceptionState& exception);
  static int setInterval(ExecutingContext* context,
                         std::shared_ptr<QJSFunction> handler,
                         int32_t timeout,
                         ExceptionState& exception);
  static int setInterval(ExecutingContext* context, std::shared_ptr<QJSFunction> handler, ExceptionState& exception);
  static void clearTimeout(ExecutingContext* context, int32_t timerId, ExceptionState& exception);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H
