/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_UI_TASK_QUEUE_H
#define KRAKENBRIDGE_UI_TASK_QUEUE_H

#include "closure.h"
#include "ref_counter.h"
#include "ref_ptr.h"
#include <deque>
#include <mutex>

namespace foundation {

using Task = void(*)(void*);

class UITaskMessageQueue;

static std::mutex ui_task_creation_mutex_;
static fml::RefPtr<UITaskMessageQueue> instance_;

class UITaskMessageQueue : public fml::RefCountedThreadSafe<UITaskMessageQueue> {
public:
  static fml::RefPtr<UITaskMessageQueue> instance() {
    std::lock_guard<std::mutex> guard(ui_task_creation_mutex_);
    if (!instance_) {
      instance_ = fml::MakeRefCounted<UITaskMessageQueue>();
    }
    return instance_;
  };

  void registerTask(const Task& task, void* data);
  void flushTaskFromUIThread();

private:
  struct TaskData {
    TaskData(const Task &task, void *data): task(task), data(data) {};
    Task task;
    void *data;
  };

  mutable std::mutex queue_mutex_;
  std::deque<TaskData*> queue;

  FML_FRIEND_MAKE_REF_COUNTED(UITaskMessageQueue);
  FML_FRIEND_REF_COUNTED_THREAD_SAFE(UITaskMessageQueue);
};

} // namespace foundation

#endif // KRAKENBRIDGE_UI_TASK_QUEUE_H
