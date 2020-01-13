/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_SCREEN_H
#define KRAKEN_SCREEN_H

#include "jsa.h"

namespace kraken {
namespace binding {

void bindScreen(alibaba::jsa::JSContext *context);

void invokeUpdateScreen(alibaba::jsa::JSContext *context, int width, int height,
                        int availWidth, int availHeight);

} // namespace binding
} // namespace kraken

#endif /* KRAKEN_SCREEN_H */
