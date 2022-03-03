/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_callback.h"

namespace kraken {

ModuleCallback::ModuleCallback(QJSFunction* function) : function_(function) {}

QJSFunction* ModuleCallback::value() {
  return function_;
}

void ModuleCallback::Trace(GCVisitor* visitor) const {
  function_->Trace(visitor);
}

void ModuleCallback::Dispose() const {
  function_->Dispose();
}

}  // namespace kraken
