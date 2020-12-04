/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "ui_task_queue.h"
#include "ref_ptr.h"
#include <mutex>

namespace foundation {

void UITaskMessageQueue::registerTask(const Task &task, void* data) {
  std::lock_guard<std::mutex> guard(queue_mutex_);
  auto taskData = new TaskData(task, data);
  queue.emplace_back(taskData);
}

void UITaskMessageQueue::flushTaskFromUIThread() {
  std::lock_guard<std::mutex> guard(queue_mutex_);
  auto begin = std::begin(queue);
  auto end = std::end(queue);
  TaskData *taskData;
  while (begin != end) {
    taskData = *begin;
    taskData->task(taskData->data);
    delete taskData;
    ++begin;
  }
  queue.clear();
}

}
