/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <memory>
#include "bindings/qjs/dom/event_target.h"

using TEST_OnEventTargetDisposed = void (*)(kraken::binding::qjs::EventTargetInstance *eventTargetInstance);
using TEST_PendingJobCallback = void (*)(void *ptr);

struct UnitTestEnv {
  TEST_OnEventTargetDisposed onEventTargetDisposed{nullptr};
};


std::shared_ptr<UnitTestEnv> TEST_getEnv(int32_t contextUniqueId);
void TEST_dispatchEvent(kraken::binding::qjs::EventTargetInstance *eventTarget, std::string event);
void TEST_registerEventTargetDisposedCallback(int32_t contextUniqueId, TEST_OnEventTargetDisposed callback);
void TEST_schedulePendingJob(void *ptr, TEST_PendingJobCallback callback);
void TEST_flushPendingJob();
