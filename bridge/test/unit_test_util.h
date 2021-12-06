/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <memory>
#include "bindings/qjs/dom/event_target.h"

using OnEventTargetDisposed = void (*)(kraken::binding::qjs::EventTargetInstance* eventTargetInstance);

struct UnitTestEnv {
  OnEventTargetDisposed onEventTargetDisposed{nullptr};
};

std::shared_ptr<UnitTestEnv> getUnitTestEnv(int32_t contextUniqueId);

void dispatchEvent(kraken::binding::qjs::EventTargetInstance* eventTarget, std::string event);

void registerEventTargetDisposedCallback(int32_t contextUniqueId, OnEventTargetDisposed callback);
