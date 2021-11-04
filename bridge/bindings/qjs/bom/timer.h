/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TIMER_H
#define KRAKENBRIDGE_TIMER_H

#include "bindings/qjs/js_context.h"

namespace kraken::binding::qjs {

struct TimerCallbackContext {
  JSValue callback;
  JSContext* context;
  list_head link;
};

void bindTimer(std::unique_ptr<JSContext>& context);

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_TIMER_H
