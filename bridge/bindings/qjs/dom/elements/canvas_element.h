/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CANVAS_ELEMENT_H
#define KRAKENBRIDGE_CANVAS_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {

struct NativeCanvasRenderingContext2D {
  CallNativeMethods callNativeMethods{nullptr};
};

}


#endif //KRAKENBRIDGE_CANVAS_ELEMENT_H
