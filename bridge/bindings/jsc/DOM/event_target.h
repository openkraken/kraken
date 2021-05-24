/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_TARGET_H
#define KRAKENBRIDGE_EVENT_TARGET_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context_internal.h"
#include "dart_methods.h"
#include "foundation/logging.h"
#include "foundation/ui_task_queue.h"
#include "include/kraken_bridge.h"
#include <array>
#include <atomic>
#include <condition_variable>
#include <unordered_map>

namespace kraken::binding::jsc {

void bindEventTarget(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_EVENT_TARGET_H
