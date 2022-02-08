/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MODULE_LISTENER_CONTAINER_H
#define KRAKENBRIDGE_MODULE_LISTENER_CONTAINER_H

#include "module_listener.h"
#include <forward_list>

namespace kraken {

class ModuleListenerContainer final {
 public:

  void addModuleListener(ModuleListener* listener);
  void trace(GCVisitor* visitor);

 private:
  std::forward_list<ModuleListener*> m_listeners;
};

}

#endif  // KRAKENBRIDGE_MODULE_LISTENER_CONTAINER_H
