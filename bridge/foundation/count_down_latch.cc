/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include "count_down_latch.h"

#include "logging.h"

namespace foundation {

CountDownLatch::CountDownLatch(size_t count) : count_(count) {
  if (count_ == 0) {
    waitable_event_.Signal();
  }
}

CountDownLatch::~CountDownLatch() = default;

void CountDownLatch::Wait() { waitable_event_.Wait(); }

void CountDownLatch::CountDown() {
  if (--count_ == 0) {
    waitable_event_.Signal();
  }
}

} // namespace foundation
