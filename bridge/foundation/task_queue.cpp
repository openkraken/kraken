/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "task_queue.h"

namespace foundation {

int32_t TaskQueue::registerTask(const Task &task, void *data) {
  auto taskData = new TaskData(task, data);
  m_map[id++] = taskData;
  return id - 1;
}

void TaskQueue::dispatchTask(int32_t taskId) {
  if (m_map.count(taskId) > 0) {
    m_map[taskId]->task(m_map[taskId]->data);
    delete m_map[taskId];
    m_map.erase(taskId);
  }
}

} // namespace foundation
