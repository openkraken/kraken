/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TASK_QUEUE_H
#define KRAKENBRIDGE_TASK_QUEUE_H

#include "closure.h"
#include "ref_counter.h"
#include "ref_ptr.h"
#include <mutex>
#include <unordered_map>

namespace foundation {

class TaskQueue;
using Task = void (*)(void *);

class TaskQueue : public fml::RefCountedThreadSafe<TaskQueue> {
public:
  virtual int32_t registerTask(const Task &task, void *data);
  void dispatchTask(int32_t taskId);

private:
  struct TaskData {
    TaskData(const Task &task, void *data) : task(task), data(data){};
    Task task;
    void *data;
  };

  std::unordered_map<int, TaskData *> m_map;
  int64_t id{0};

  FML_FRIEND_MAKE_REF_COUNTED(TaskQueue);
  FML_FRIEND_REF_COUNTED_THREAD_SAFE(TaskQueue);
};

} // namespace foundation

#endif // KRAKENBRIDGE_TASK_QUEUE_H
