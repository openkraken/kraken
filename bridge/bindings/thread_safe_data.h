/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#ifndef THREAD_SAFE_DATA_H
#define THREAD_SAFE_DATA_H

#include <atomic>
#include <mutex>
#include <condition_variable>

/// an data structure hold an standlone data which is thread safe to read and write
template<typename T>
class ThreadSafeData {
public:
  ThreadSafeData() {}
  ThreadSafeData(T value): instance(value) {}
  ThreadSafeData& operator = (ThreadSafeData&) = delete;

  void set(T t) {
    std::lock_guard<std::mutex> lk(mut);
    instance = t;
    condition.notify_one();
  }

  void get(T& t) {
    std::lock_guard<std::mutex> lk(mut);
    t = instance;
    condition.notify_one();
  }

private:
  std::mutex mut;
  std::atomic<T> instance;
  std::condition_variable condition;
};

#endif /* THREAD_SAFE_DATA_H */
