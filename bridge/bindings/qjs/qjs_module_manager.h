/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_QJS_MODULE_MANAGER_H
#define KRAKENBRIDGE_QJS_MODULE_MANAGER_H

#include <quickjs/quickjs.h>

namespace kraken {

class QJSModuleManager final {
 public:
  static void installGlobalFunctions(JSContext* ctx);
};

}

#endif  // KRAKENBRIDGE_QJS_MODULE_MANAGER_H
