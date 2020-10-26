/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef BRIDGE_TIMER_H
#define BRIDGE_TIMER_H

#include "jsa.h"
#include <memory>

namespace kraken::binding::jsa {
using namespace alibaba::jsa;

void bindTimer(std::unique_ptr<JSContext> &context);

} // namespace kraken

#endif // BRIDGE_TIMER_H
