/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MOUSE_EVENT_H
#define KRAKENBRIDGE_MOUSE_EVENT_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context_internal.h"
#include <vector>

namespace kraken::binding::jsc {

void bindMouseEvent(std::unique_ptr<JSContext> &context);


} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_MOUSE_EVENT_H
