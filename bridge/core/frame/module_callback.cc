/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_callback.h"

namespace kraken {

ModuleCallback::ModuleCallback(QJSFunction* function): m_function(function) {}

QJSFunction* ModuleCallback::value() {
  return m_function;
}

void ModuleCallback::trace(GCVisitor* visitor) const {
  m_function->trace(visitor);
}

void ModuleCallback::dispose() const {
  m_function->dispose();
}

}
