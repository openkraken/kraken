/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef THREAD_SAFE_ARRAY_H
#define THREAD_SAFE_ARRAY_H

#include <atomic>
#include <condition_variable>
#include <vector>
#include <mutex>

template <class T> class ThreadSafeArray {
public:
  ThreadSafeArray() {}
  ThreadSafeArray &operator=(ThreadSafeArray &) = delete;

  void push(T value) {
    std::lock_guard<std::mutex> lk(mut);
    list.emplace_back(value);
    condition.notify_one();
  }

  int length() {
    std::lock_guard<std::mutex> lk(mut);
    int len = list.size();
    condition.notify_one();
    return len;
  }

  void removeAt(int index) {
    std::lock_guard<std::mutex> lk(mut);
    list.erase(index);
    condition.notify_one();
  }

  void get(int index, T &value) {
    std::unique_lock<std::mutex> lk(mut);
    value = list[index];
    lk.unlock();
  }

  void clear() {
    std::unique_lock<std::mutex> lk(mut);
    list.clear();
    lk.unlock();
  }

private:
  std::mutex mut;
  std::vector<T> list;
  std::condition_variable condition;
};

#endif // THREAD_SAFE_ARRAY_H
