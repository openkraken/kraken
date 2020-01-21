/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef THREAD_SAFE_MAP_H
#define THREAD_SAFE_MAP_H

#include <atomic>
#include <condition_variable>
#include <map>
#include <mutex>

template <typename Key, class T> class ThreadSafeMap {
public:
  ThreadSafeMap() {}
  ThreadSafeMap &operator=(ThreadSafeMap &) = delete;

  void set(Key key, T value) {
    std::lock_guard<std::mutex> lk(mut);
    map[key] = value;
    condition.notify_one();
  }

  void erase(Key key) {
    std::lock_guard<std::mutex> lk(mut);
    map.erase(key);
    condition.notify_one();
  }

  void get(Key key, T &value) {
    std::unique_lock<std::mutex> lk(mut);
    value = map[key];
    lk.unlock();
  }

  bool has(Key key) {
    std::unique_lock<std::mutex> lk(mut);
    bool hasValue = map.contains(key);
    lk.unlock();
    return hasValue;
  }

  void reset() {
    std::unique_lock<std::mutex> lk(mut);
    map.clear();
    lk.unlock();
  }

private:
  std::mutex mut;
  std::map<Key, T> map;
  std::condition_variable condition;
};

#endif // THREAD_SAFE_MAP_H
