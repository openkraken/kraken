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

// ModuleCallback is an asynchronous callback function, usually from the 4th parameter of `kraken.invokeModule` function.
// When the asynchronous operation on the Dart side ends, the callback is will called and to return to the JS executing environment.
class ModuleCallback : public GarbageCollected<ModuleCallback> {
 public:
  explicit ModuleCallback(QJSFunction* function);

  QJSFunction* value();

  void trace(GCVisitor*visitor) const override;
  void dispose() const override;

  list_head link;

private:
  QJSFunction* m_function{nullptr};
};



}

#endif  // KRAKENBRIDGE_MODULE_CALLBACK_H
