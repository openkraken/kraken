/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_callback_coordinator.h"

namespace kraken {

void ModuleCallbackCoordinator::addModuleCallbacks(ModuleCallback* callback) {
  list_add_tail(&m_listeners, &callback->link);
}

void ModuleCallbackCoordinator::removeModuleCallbacks(ModuleCallback* callback) {
  list_del(&callback->link);
}

ModuleCallbackCoordinator::ModuleCallbackCoordinator() {
  init_list_head(&m_listeners);
}

void ModuleCallbackCoordinator::trace(GCVisitor* visitor) {
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &m_listeners) {
      auto* callback = list_entry(el, ModuleCallback, link);
      visitor->trace(callback->toQuickJS());
    }
  }
}

}  // namespace kraken
