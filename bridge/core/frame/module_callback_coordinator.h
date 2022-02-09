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

class ModuleCallbackCoordinator final {
 public:
  ModuleCallbackCoordinator();

  void addModuleCallbacks(ModuleCallback* callback);
  void removeModuleCallbacks(ModuleCallback* callback);

  void trace(GCVisitor* visitor);

 private:
  list_head m_listeners;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_CALLBACK_COORDINATOR_H
