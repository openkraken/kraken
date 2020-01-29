/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "jsa.h"

namespace kraken {
namespace binding {

using namespace alibaba::jsa;

void bindElement(std::unique_ptr<JSContext> &context);

}
}

#endif // KRAKENBRIDGE_ELEMENT_H
