/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MODULE_CALLBACK_H
#define KRAKENBRIDGE_MODULE_CALLBACK_H

#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/qjs_function.h"
#include <quickjs/list.h>

namespace kraken {

class ModuleCallback;

// In C++ code, We can not use offsetof to access members of structures or classes that are not Plain Old Data Structures.
// So we use struct which support offsetof.
struct ModuleCallbackLinker {
  ModuleCallback* ptr;
  list_head link;
};

// ModuleCallback is an asynchronous callback function, usually from the 4th parameter of `kraken.invokeModule` function.
// When the asynchronous operation on the Dart side ends, the callback is will called and to return to the JS executing environment.
class ModuleCallback : public GarbageCollected<ModuleCallback> {
 public:
  explicit ModuleCallback(QJSFunction* function);

  QJSFunction* value();

  void trace(GCVisitor*visitor) const override;
  void dispose() const override;

  ModuleCallbackLinker linker{this};

private:
  QJSFunction* m_function{nullptr};
};


}

#endif  // KRAKENBRIDGE_MODULE_CALLBACK_H
