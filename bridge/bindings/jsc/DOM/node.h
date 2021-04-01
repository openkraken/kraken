/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_NODE_H
#define KRAKENBRIDGE_NODE_H

#include <array>
#include <vector>
#include "event_target.h"
#include "include/kraken_bridge.h"
#include "text_node.h"

namespace kraken::binding::jsc {

void bindNode(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_NODE_H
