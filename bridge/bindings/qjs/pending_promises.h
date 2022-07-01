/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_PENDING_PROMISES_H_
#define KRAKENBRIDGE_BINDINGS_QJS_PENDING_PROMISES_H_

#include <quickjs/quickjs.h>
#include <vector>
#include "script_promise.h"

namespace kraken {

class PendingPromises {
 public:
  PendingPromises() = default;
  void TrackPendingPromises(ScriptPromise&& promise);

 private:
  std::vector<ScriptPromise> promises_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_PENDING_PROMISES_H_
