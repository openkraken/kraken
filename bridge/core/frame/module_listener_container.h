/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MODULE_LISTENER_CONTAINER_H
#define KRAKENBRIDGE_MODULE_LISTENER_CONTAINER_H

#include <forward_list>
#include "module_listener.h"

namespace kraken {

class ModuleListenerContainer final {
 public:
  void addModuleListener(std::shared_ptr<ModuleListener> listener);
  void trace(GCVisitor* visitor);

 private:
  std::forward_list<std::shared_ptr<ModuleListener>> m_listeners;
  friend ModuleListener;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_LISTENER_CONTAINER_H
