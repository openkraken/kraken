/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_THREAD_SAFE_STACK_H
#define KRAKENBRIDGE_THREAD_SAFE_STACK_H

#include <atomic>
#include <condition_variable>
#include <list>
#include <mutex>
#include <stdexcept>
#include <thread>

namespace kraken {
namespace foundation {

template <typename T> class ThreadSafeStack {
public:
  enum QueueResult { OK, CLOSED };

  explicit ThreadSafeStack(size_t maxSize = 0) : state(State::OPEN), currentSize(0), maxSize(maxSize) {}

  void push(T const &v) {
    std::list<T> tmpList;
    tmpList.push_back(v);

    {
      std::unique_lock<std::mutex> lock(mutex);

      while (currentSize == maxSize)
        cvPush.wait(lock);

      if (state == State::CLOSED) throw std::runtime_error("Trying to push to a closed queue.");

      currentSize += 1;
      list.splice(list.end(), tmpList, tmpList.begin());

      if (currentSize == 1u) cvPop.notify_one();
    }
  }

  void push(T &&v) {
    std::list<T> tmpList;
    tmpList.push_back(v);

    {
      std::unique_lock<std::mutex> lock(mutex);

      while (currentSize == maxSize)
        cvPush.wait(lock);

      if (state == State::CLOSED) throw std::runtime_error("Trying to push to a closed queue.");

      currentSize += 1;
      list.splice(list.end(), tmpList, tmpList.begin());

      cvPop.notify_one();
    }
  }

  QueueResult pop(T &v) {
    decltype(list) tmpList;

    {
      std::unique_lock<std::mutex> lock(mutex);

      if (list.empty()) {
        return CLOSED;
      }

      currentSize -= 1;
      tmpList.splice(tmpList.begin(), list, list.begin());
      cvPush.notify_one();
    }

    v = tmpList.front();

    return OK;
  }

  void close() noexcept {
    std::unique_lock<std::mutex> lock(mutex);
    state = State::CLOSED;

    cvPop.notify_all();
  }

private:
  enum class State { OPEN, CLOSED };

  State state;
  std::atomic<size_t> currentSize;
  size_t maxSize;
  std::condition_variable cvPush, cvPop;
  std::mutex mutex;
  std::list<T> list;
};

} // namespace foundation
} // namespace kraken

#endif // KRAKENBRIDGE_THREAD_SAFE_STACK_H
