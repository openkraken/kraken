/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MODULE_LISTENER_H
#define KRAKENBRIDGE_MODULE_LISTENER_H

#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/qjs_function.h"

namespace kraken {

// ModuleListener is an persistent callback function. Registered from user with `kraken.addModuleListener` method.
// When module event triggered at dart side, All module listener will be invoked and let user to dispatch further operations.
class ModuleListener : public GarbageCollected<ModuleListener> {
 public:
  explicit ModuleListener(QJSFunction* function);

 private:
  void trace(GCVisitor* visitor) const override;
  void dispose() const override;

  QJSFunction* m_function{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_LISTENER_H
