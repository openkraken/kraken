/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "module_listener.h"

#include <utility>

namespace kraken {

std::shared_ptr<ModuleListener> ModuleListener::Create(const std::shared_ptr<QJSFunction>& function) {
  return std::make_shared<ModuleListener>(function);
}

ModuleListener::ModuleListener(std::shared_ptr<QJSFunction> function) : function_(std::move(function)) {}

}  // namespace kraken
