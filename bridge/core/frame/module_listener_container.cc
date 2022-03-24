/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_listener_container.h"

namespace kraken {

void ModuleListenerContainer::AddModuleListener(const std::shared_ptr<ModuleListener>& listener) {
  listeners_.push_front(listener);
}

}  // namespace kraken
