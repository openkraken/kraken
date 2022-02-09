/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_listener.h"

namespace kraken {

ModuleListener::ModuleListener(QJSFunction* function) : m_function(function) {}

void ModuleListener::trace(GCVisitor* visitor) const {
  m_function->trace(visitor);
}

void ModuleListener::dispose() const {
  m_function->dispose();
}

}  // namespace kraken
