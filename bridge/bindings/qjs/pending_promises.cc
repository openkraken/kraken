/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "pending_promises.h"
#include "script_promise.h"

namespace kraken {

void PendingPromises::TrackPendingPromises(ScriptPromise&& promise) {
  promises_.emplace_back(promise);
}

}  // namespace kraken
