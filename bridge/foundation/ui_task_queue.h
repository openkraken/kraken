/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_UI_TASK_QUEUE_H
#define KRAKENBRIDGE_UI_TASK_QUEUE_H

#include "task_queue.h"

namespace kraken {

class UITaskQueue : public TaskQueue {
 public:
  static fml::RefPtr<UITaskQueue> instance(int32_t contextId) {
    std::lock_guard<std::mutex> guard(ui_task_creation_mutex_);
    if (!instance_) {
      instance_ = fml::MakeRefCounted<UITaskQueue>();
      instance_->m_contextId = contextId;
    }
    return instance_;
  };
  int32_t registerTask(const Task& task, void* data);

 private:
  static std::mutex ui_task_creation_mutex_;
  static fml::RefPtr<UITaskQueue> instance_;
  int m_contextId;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_UI_TASK_QUEUE_H
