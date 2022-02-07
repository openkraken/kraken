/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H
#define KRAKENBRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H

#include "core/executing_context.h"

namespace kraken {

class WindowOrWorkerGlobalScope {
 public:
  static int setTimeout(ExecutionContext* context, );
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_WINDOW_OR_WORKER_GLOBAL_SCROPE_H
