/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_UI_COMMAND_QUEUE_H
#define KRAKENBRIDGE_UI_COMMAND_QUEUE_H

#include "closure.h"
#include "include/kraken_bridge.h"
#include "logging.h"
#include <vector>
#include <unordered_map>

namespace foundation {

class UICommandTaskMessageQueue;

// An un thread safe queue used for dart side to read ui command items.
class UICommandTaskMessageQueue {
public:
  UICommandTaskMessageQueue() = delete;
  explicit UICommandTaskMessageQueue(int32_t contextId);
  static UICommandTaskMessageQueue* instance(int32_t contextId);

  void registerCommand(int64_t id, int64_t type, NativeString **args, int64_t length, void* nativePtr);
  UICommandItem *data();
  int64_t size();
  void clear();

private:
  int32_t contextId;
  std::atomic<bool> update_batched{false};
  std::vector<UICommandItem> queue;
};

} // namespace foundation

#endif // KRAKENBRIDGE_UI_COMMAND_QUEUE_H
