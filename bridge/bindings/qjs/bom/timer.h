/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TIMER_H
#define KRAKENBRIDGE_TIMER_H

#include "bindings/qjs/js_context.h"


namespace kraken::binding::qjs {

void bindTimer(std::unique_ptr<JSContext> &context);

}

#endif // KRAKENBRIDGE_TIMER_H
