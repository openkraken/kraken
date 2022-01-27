/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

namespace kraken {

UICommandCallbackQueue* UICommandCallbackQueue::instance() {
  static UICommandCallbackQueue* queue = nullptr;

  if (queue == nullptr) {
    queue = new UICommandCallbackQueue();
  }

  return queue;
}

void UICommandCallbackQueue::flushCallbacks() {
  for (auto& item : queue) {
    item.callback(item.data);
  }
  queue.clear();
}

void UICommandCallbackQueue::registerCallback(const Callback& callback, void* data) {
  CallbackItem item{callback, data};
  queue.emplace_back(item);
}

}  // namespace kraken
