/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "ui_task_queue.h"
#include "ref_ptr.h"
#include <mutex>

namespace foundation {

void UITaskMessageQueue::registerTask(const fml::closure &task) {
  std::lock_guard<std::mutex> guard(queue_mutex_);
  queue.emplace_back(task);
}

void UITaskMessageQueue::flushTaskFromUIThread() {
  std::lock_guard<std::mutex> guard(queue_mutex_);
  auto begin = std::begin(queue);
  auto end = std::end(queue);
  Task task;
  while (begin != end) {
    task = *begin;
    task();
    ++begin;
  }
  queue.clear();
}

}
