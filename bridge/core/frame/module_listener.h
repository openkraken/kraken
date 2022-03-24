/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MODULE_LISTENER_H
#define KRAKENBRIDGE_MODULE_LISTENER_H

#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/qjs_function.h"

namespace kraken {

class ModuleCallbackCoordinator;
class ModuleListenerContainer;

// ModuleListener is an persistent callback function. Registered from user with `kraken.addModuleListener` method.
// When module event triggered at dart side, All module listener will be invoked and let user to dispatch further operations.
class ModuleListener {
 public:
  static std::shared_ptr<ModuleListener> Create(const std::shared_ptr<QJSFunction>& function);
  explicit ModuleListener(std::shared_ptr<QJSFunction> function);

 private:

  std::shared_ptr<QJSFunction> function_{nullptr};

  friend ModuleListenerContainer;
  friend ModuleCallbackCoordinator;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_LISTENER_H
