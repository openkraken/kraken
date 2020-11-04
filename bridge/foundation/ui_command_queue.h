/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_UI_COMMAND_QUEUE_H
#define KRAKENBRIDGE_UI_COMMAND_QUEUE_H

#include "closure.h"
#include "include/kraken_bridge.h"
#include <vector>

namespace foundation {

class UICommandTaskMessageQueue;

static UICommandTaskMessageQueue *instanceList_[8];

// An un thread safe queue used for dart side to read ui command items.
class UICommandTaskMessageQueue {
  UICommandTaskMessageQueue() = default;

public:
  static UICommandTaskMessageQueue* instance(int32_t contextId) {
    if (!instanceList_[contextId]) {
      instanceList_[contextId] = new UICommandTaskMessageQueue();
      // preallocate 100 commandItem space.
      instanceList_[contextId]->queue.reserve(1000);
    }
    return instanceList_[contextId];
  };

  void registerCommand(int64_t id, int8_t type, NativeString **args, size_t length, void* nativePtr);
  UICommandItem **data() {
    return queue.data();
  };
  size_t size() {
    return queue.size();
  }
  void clear() {
    queue.clear();
  }

private:
  std::vector<UICommandItem *> queue;
};

} // namespace foundation

#endif // KRAKENBRIDGE_UI_COMMAND_QUEUE_H
