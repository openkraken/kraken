/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "flushUITask.h"
#include "thread_safe_stack.h"
#include <memory>

namespace kraken {
namespace foundation {

struct TaskItem {
  Task task;
  void *context;
};

ThreadSafeStack<std::shared_ptr<TaskItem>> stack{20};

void flushUITask() {
  std::shared_ptr<TaskItem> item;
  ThreadSafeStack<std::shared_ptr<TaskItem>>::QueueResult result = stack.pop(item);
  while (result != ThreadSafeStack<std::shared_ptr<TaskItem>>::CLOSED) {
    item->task(item->context);
    result = stack.pop(item);
  }
}

void registerUITask(Task task, void *context) {
  std::shared_ptr<TaskItem> item = std::make_unique<TaskItem>();
  item->task = task;
  item->context = context;
  stack.push(item);
}

} // namespace foundation
} // namespace kraken
