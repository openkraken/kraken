/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TOBLOB_H
#define KRAKENBRIDGE_TOBLOB_H

#include "jsa.h"
#include <memory>

namespace kraken::binding::jsa {
using namespace alibaba::jsa;

void bindToBlob(std::unique_ptr<JSContext> &context);

} // namespace kraken

#endif // KRAKENBRIDGE_TOBLOB_H
