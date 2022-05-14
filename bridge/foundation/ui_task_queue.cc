/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "ui_task_queue.h"

namespace kraken {
std::mutex UITaskQueue::ui_task_creation_mutex_{};
fml::RefPtr<UITaskQueue> UITaskQueue::instance_{};

int32_t UITaskQueue::registerTask(const Task& task, void* data) {
  int32_t taskId = TaskQueue::registerTask(task, data);
  return taskId;
}

}  // namespace kraken
