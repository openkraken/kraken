/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_KRAKEN_H
#define KRAKENBRIDGE_KRAKEN_H

#include "js_context.h"

namespace kraken::binding::qjs {
void bindKraken(std::unique_ptr<JSContext> &context);
}

#endif // KRAKENBRIDGE_KRAKEN_H
