/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef THREAD_SAFE_ARRAY_H
#define THREAD_SAFE_ARRAY_H

#include <atomic>
#include <condition_variable>
#include <mutex>
#include <vector>

template <class T> class ThreadSafeArray {
public:
  ThreadSafeArray() {}
  ThreadSafeArray &operator=(ThreadSafeArray &) = delete;

  void push(const T &value) {
    std::unique_lock<std::mutex> lock(mutex);
    list.emplace_back(value);
  }

  void push(T &&value) {
    std::unique_lock<std::mutex> lock(mutex);
    list.emplace_back(std::move(value));
  }

  void pop(const T &value) {
    std::unique_lock<std::mutex> lock(mutex);
    value = list.back();
    list.pop_back();
  }

  void removeAt(int index) {
    std::unique_lock<std::mutex> lock(mutex);
    list.erase(index);
  }

  std::unique_lock<std::mutex> getLock() {
    std::unique_lock<std::mutex> lock(mutex);
    return lock;
  }

  std::vector<T> *getVector() {
    return &list;
  }

  void clear() {
    std::lock_guard<std::mutex> lock(mutex);
    list.clear();
  }

private:
  std::mutex mutex;
  std::vector<T> list;
};

#endif // THREAD_SAFE_ARRAY_H
