/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MODULE_CALLBACK_COORDINATOR_H
#define KRAKENBRIDGE_MODULE_CALLBACK_COORDINATOR_H

#include <forward_list>
// Quickjs's linked-list are more efficient than STL forward_list.
#include <quickjs/list.h>
#include "module_callback.h"
#include "module_manager.h"

namespace kraken {

class ModuleListener;

class ModuleCallbackCoordinator final {
 public:
  ModuleCallbackCoordinator();

  void AddModuleCallbacks(ModuleCallback* callback);
  void RemoveModuleCallbacks(ModuleCallback* callback);

  void Trace(GCVisitor* visitor);

 private:
  list_head listeners_;

  friend ModuleListener;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_CALLBACK_COORDINATOR_H
