/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_listener_container.h"

namespace kraken {

void ModuleListenerContainer::addModuleListener(std::shared_ptr<ModuleListener> listener) {
  m_listeners.insert_after(m_listeners.end(), listener);
}

void ModuleListenerContainer::trace(GCVisitor* visitor) {
  for (auto& listener : m_listeners) {
    listener->function_->Trace(visitor);
  }
}

}  // namespace kraken
