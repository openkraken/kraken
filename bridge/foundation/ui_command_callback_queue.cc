/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "ui_command_callback_queue.h"

namespace foundation {

UICommandCallbackQueue *UICommandCallbackQueue::instance(int32_t contextId) {
  static std::unordered_map<int32_t, UICommandCallbackQueue *> instanceMap;

  if (instanceMap.count(contextId) == 0) {
    instanceMap[contextId] = new UICommandCallbackQueue();
  }

  return instanceMap[contextId];
}

void UICommandCallbackQueue::flushCallbacks() {
  for (auto &item : queue) {
    item.callback(item.data);
  }
  queue.clear();
}

void UICommandCallbackQueue::registerCallback(const Callback &callback, void *data) {
  CallbackItem item{callback, data};
  queue.emplace_back(item);
}

} // namespace foundation
