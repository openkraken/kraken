/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CLOSURE_H
#define KRAKENBRIDGE_CLOSURE_H

#include <functional>

namespace fml {
using closure = std::function<void()>;
}

#endif  // KRAKENBRIDGE_CLOSURE_H
