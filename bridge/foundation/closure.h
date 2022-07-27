/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

#ifndef BRIDGE_CLOSURE_H
#define BRIDGE_CLOSURE_H

#include <functional>

namespace fml {
using closure = std::function<void()>;
}

#endif  // BRIDGE_CLOSURE_H
