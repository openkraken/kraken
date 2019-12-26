// Copyright 2019 The Alibaba Authors. All rights reserved.
// Author: chuyi

#ifndef KRAKEN_FOUNDATION_THREAD_UTILS_H_
#define KRAKEN_FOUNDATION_THREAD_UTILS_H_

#include <string>

namespace kraken {
namespace foundation {
void SetCurrentThreadName(const std::string &name);
}
} // namespace kraken

#endif // KRAKEN_FOUNDATION_THREAD_UTILS_H_