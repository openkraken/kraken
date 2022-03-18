/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_H_
#define KRAKENBRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_H_

#include <quickjs/quickjs.h>
#include "foundation/macros.h"

namespace kraken {

// ScriptPromise is the class for representing Promise values in C++ world.
// ScriptPromise holds a Promise.
// So holding a ScriptPromise as a member variable in DOM object causes
// memory leaks since it has a reference from C++ to QuickJS.
class ScriptPromise final {
  KRAKEN_DISALLOW_NEW();

 public:

  JSValue ToQuickJS();
 private:


};

}

#endif  // KRAKENBRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_H_
