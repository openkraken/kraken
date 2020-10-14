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

using Task = fml::closure;
using TaskQueue = std::deque<Task>;

class UITaskMessageQueue;

static std::mutex creation_mutex_;
static fml::RefPtr<UITaskMessageQueue> instance_;

class UITaskMessageQueue : public fml::RefCountedThreadSafe<UITaskMessageQueue> {
public:
  static fml::RefPtr<UITaskMessageQueue> instance() {
    std::lock_guard<std::mutex> guard(creation_mutex_);
    if (!instance_) {
      instance_ = fml::MakeRefCounted<UITaskMessageQueue>();
    }
    return instance_;
  };

  void registerTask(const fml::closure& task);
  void flushTaskFromUIThread();

private:
  mutable std::mutex queue_mutex_;
  TaskQueue queue;

  FML_FRIEND_MAKE_REF_COUNTED(UITaskMessageQueue);
  FML_FRIEND_REF_COUNTED_THREAD_SAFE(UITaskMessageQueue);
};

} // namespace foundation

#endif // KRAKENBRIDGE_UI_TASK_QUEUE_H
