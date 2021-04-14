/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "task_queue.h"

namespace foundation {

int32_t TaskQueue::registerTask(const Task &task, void *data) {
  std::lock_guard<std::mutex> guard(queue_mutex_);
  auto taskData = new TaskData(task, data);
  queue.emplace_back(taskData);
  return queue.size() - 1;
}

void TaskQueue::flushTask() {
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

void TaskQueue::dispatchTask(int32_t taskId) {
  std::lock_guard<std::mutex> guard(queue_mutex_);
  if (queue[taskId]) {
    queue[taskId]->task(queue[taskId]->data);
  }
}

} // namespace foundation
