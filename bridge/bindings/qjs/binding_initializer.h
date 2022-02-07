/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDING_INITIALIZER_H
#define KRAKENBRIDGE_BINDING_INITIALIZER_H

#include <quickjs/quickjs.h>

namespace kraken {

void installBindings(JSContext* ctx);

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDING_INITIALIZER_H
