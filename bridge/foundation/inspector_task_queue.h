/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_INSPECTOR_TASK_QUEUE_H
#define BRIDGE_INSPECTOR_TASK_QUEUE_H

#include "task_queue.h"
#include "webf_foundation.h"

namespace foundation {

class InspectorTaskQueue;
using Task = void (*)(void*);

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
  int32_t registerTask(const Task& task, void* data) override {
    int32_t taskId = TaskQueue::registerTask(task, data);
    assert(std::this_thread::get_id() == getUIThreadId());
    return taskId;
  }

 private:
  int32_t m_contextId{-1};
  static std::mutex inspector_task_creation_mutex_;
  static fml::RefPtr<InspectorTaskQueue> instance_;
};

}  // namespace foundation

#endif  // BRIDGE_INSPECTOR_TASK_QUEUE_H
