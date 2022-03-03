/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_listener.h"

namespace kraken {

ModuleListener::ModuleListener(QJSFunction* function) : m_function(function) {}

void ModuleListener::Trace(GCVisitor* visitor) const {
  m_function->Trace(visitor);
}

void ModuleListener::Dispose() const {
  m_function->Dispose();
}

}  // namespace kraken
