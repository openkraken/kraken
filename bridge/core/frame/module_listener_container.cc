/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_listener_container.h"

namespace kraken {

void ModuleListenerContainer::addModuleListener(ModuleListener* listener) {
  m_listeners.insert_after(m_listeners.end(), listener);
}

void ModuleListenerContainer::trace(GCVisitor* visitor) {
  for (auto& listener : m_listeners) {
    listener->m_function->Trace(visitor);
  }
}

}  // namespace kraken
