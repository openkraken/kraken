/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#ifndef KRAKEN_FOUNDATION_COUNT_DOWN_LATCH_H_
#define KRAKEN_FOUNDATION_COUNT_DOWN_LATCH_H_
#include <atomic>

#include "waitable_event.h"
#include "macros.h"

namespace foundation {

class CountDownLatch {
public:
  CountDownLatch(size_t count);

  ~CountDownLatch();

  void Wait();

  void CountDown();

private:
  std::atomic_size_t count_;
  ManualResetWaitableEvent waitable_event_;

  KRAKEN_DISALLOW_COPY_AND_ASSIGN(CountDownLatch);
};

} // namespace foundation
#endif // KRAKEN_FOUNDATION_COUNT_DOWN_LATCH_H_