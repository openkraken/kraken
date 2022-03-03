/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_callback_coordinator.h"

namespace kraken {

void ModuleCallbackCoordinator::AddModuleCallbacks(ModuleCallback* callback) {
  list_add_tail(&listeners_, &callback->linker.link);
}

void ModuleCallbackCoordinator::RemoveModuleCallbacks(ModuleCallback* callback) {
  list_del(&callback->linker.link);
}

ModuleCallbackCoordinator::ModuleCallbackCoordinator() {
  init_list_head(&listeners_);
}

void ModuleCallbackCoordinator::Trace(GCVisitor* visitor) {
  {
    struct list_head *el, *el1;
    list_for_each_safe(el, el1, &listeners_) {
      auto* linker = list_entry(el, ModuleCallbackLinker, link);
      linker->ptr->Trace(visitor);
    }
  }
}

}  // namespace kraken
