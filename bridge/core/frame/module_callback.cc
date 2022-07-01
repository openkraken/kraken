/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_callback.h"

namespace kraken {

std::shared_ptr<ModuleCallback> ModuleCallback::Create(std::shared_ptr<QJSFunction> function) {
  return std::make_shared<ModuleCallback>(function);
}

ModuleCallback::ModuleCallback(std::shared_ptr<QJSFunction> function) : function_(function) {}

std::shared_ptr<QJSFunction> ModuleCallback::value() {
  return function_;
}

}  // namespace kraken
