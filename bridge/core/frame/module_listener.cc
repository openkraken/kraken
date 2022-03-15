/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_listener.h"

namespace kraken {

std::shared_ptr<ModuleListener> ModuleListener::Create(std::shared_ptr<QJSFunction> function) {
  return std::make_shared<ModuleListener>(function);
}

ModuleListener::ModuleListener(std::shared_ptr<QJSFunction> function) : function_(function) {}

void ModuleListener::Trace(GCVisitor* visitor) const {
  function_->Trace(visitor);
}

void ModuleListener::Dispose() const {
  function_->Dispose();
}

}  // namespace kraken
