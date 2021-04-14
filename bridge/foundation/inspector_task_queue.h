/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_INSPECTOR_TASK_QUEUE_H
#define KRAKENBRIDGE_INSPECTOR_TASK_QUEUE_H

#include "task_queue.h"

namespace foundation {

class InspectorTaskQueue;
using Task = void(*)(void*);

class InspectorTaskQueue : public TaskQueue {
public:
  static fml::RefPtr<InspectorTaskQueue> instance(int32_t contextId) {
    std::lock_guard<std::mutex> guard(inspector_task_creation_mutex_);
    if (!instance_) {
      instance_ = fml::MakeRefCounted<InspectorTaskQueue>();
      instance_->m_contextId = contextId;
    }
    return instance_;
  };
  int32_t registerTask(const Task &task, void *data) override {
    int32_t taskId = TaskQueue::registerTask(task, data);
    assert(std::this_thread::get_id() == getUIThreadId());
    kraken::getDartMethod()->postTaskToInspectorThread(m_contextId, taskId);
    return taskId;
  }
private:
  int32_t m_contextId{-1};
  static std::mutex inspector_task_creation_mutex_;
  static fml::RefPtr<InspectorTaskQueue> instance_;
};

} // namespace foundation

#endif // KRAKENBRIDGE_INSPECTOR_TASK_QUEUE_H
