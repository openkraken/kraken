/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_callback_coordinator.h"

namespace kraken {

void ModuleCallbackCoordinator::AddModuleCallbacks(std::shared_ptr<ModuleCallback>&& callback) {
  listeners_.push_front(callback);
}

void ModuleCallbackCoordinator::RemoveModuleCallbacks(std::shared_ptr<ModuleCallback> callback) {
  listeners_.remove(callback);
}

const std::forward_list<std::shared_ptr<ModuleCallback>>* ModuleCallbackCoordinator::listeners() const {
  return &listeners_;
}

ModuleCallbackCoordinator::ModuleCallbackCoordinator() {}

}  // namespace kraken
