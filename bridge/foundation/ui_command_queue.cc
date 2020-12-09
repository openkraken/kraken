/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "ui_command_queue.h"
#include "dart_methods.h"

namespace foundation {

UICommandTaskMessageQueue::UICommandTaskMessageQueue(int32_t contextId): contextId(contextId) {}

void UICommandTaskMessageQueue::registerCommand(int64_t id, int32_t type, NativeString **args, size_t length, void* nativePtr) {
  if (!update_batched) {
    kraken::getDartMethod()->requestBatchUpdate(contextId);
    update_batched = true;
  }
  auto item = new UICommandItem(id, type, args, length, nativePtr);
  queue.push_back(item);
}

UICommandTaskMessageQueue *UICommandTaskMessageQueue::instance(int32_t contextId) {
  static std::unordered_map<int32_t, UICommandTaskMessageQueue*> instanceMap;

  if (instanceMap.count(contextId) == 0) {
    instanceMap[contextId] = new UICommandTaskMessageQueue(contextId);
  }

  return instanceMap[contextId];
}

UICommandItem **UICommandTaskMessageQueue::data() {
  return queue.data();
}

int64_t UICommandTaskMessageQueue::size() {
  return queue.size();
}

void UICommandTaskMessageQueue::clear() {
  for (auto command : queue) {
    for (size_t j = 0; j < command->length; j ++) {
      delete[] command->args[j]->string;
      delete command->args[j];
    }

    delete command;
  }
  queue.clear();
  update_batched = false;
}

}

