/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_QJS_WINDOW_H
#define KRAKENBRIDGE_QJS_WINDOW_H

#include <quickjs/quickjs.h>

namespace kraken {

class QJSWindow final {
 public:
  static void installGlobalFunctions(JSContext* ctx);
};

}

#endif  // KRAKENBRIDGE_QJS_WINDOW_H
