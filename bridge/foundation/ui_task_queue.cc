/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "ui_task_queue.h"

namespace foundation {
std::mutex UITaskQueue::ui_task_creation_mutex_{};
fml::RefPtr<UITaskQueue> UITaskQueue::instance_{};

int32_t UITaskQueue::registerTask(const Task& task, void* data) {
  int32_t taskId = TaskQueue::registerTask(task, data);
  assert(std::this_thread::get_id() != getUIThreadId());
  return taskId;
}

}  // namespace foundation
