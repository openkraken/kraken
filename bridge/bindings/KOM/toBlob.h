/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#ifndef KRAKENBRIDGE_TOBLOB_H
#define KRAKENBRIDGE_TOBLOB_H

#include <memory>
#include "jsa.h"

namespace kraken {
namespace binding {

using namespace alibaba::jsa;

void bindToBlob(std::unique_ptr<JSContext> &context);

}
}

#endif //KRAKENBRIDGE_TOBLOB_H
