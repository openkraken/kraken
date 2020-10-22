/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TOBLOB_H
#define KRAKENBRIDGE_TOBLOB_H

#include "bindings/jsc/js_context.h"
#include <memory>

namespace kraken::binding::jsc {

void bindToBlob(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_TOBLOB_H
