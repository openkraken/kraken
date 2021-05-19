/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_CLASS_H
#define KRAKENBRIDGE_HOST_CLASS_H

#include "js_context_internal.h"
#include <unordered_map>

namespace kraken::binding::jsc {

#if ENABLE_PROFILE
std::unordered_map<std::string, double> *getHostClassPropertyCallTime();
std::unordered_map<std::string, int> *getHostClassPropertyCallCount();
std::unordered_map<std::string, double> *setHostClassPropertyCallTime();
std::unordered_map<std::string, int> *setHostClassPropertyCallCount();
#endif

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_HOST_CLASS_H
