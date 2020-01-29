/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef BRIDGE_TIMER_H
#define BRIDGE_TIMER_H

#include "jsa.h"
#include <memory>

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

void bindTimer(std::unique_ptr<JSContext> &context);
void unbindTimer();
void invokeSetIntervalCallback(std::unique_ptr<JSContext> &context,
                               const int callbackId);
void invokeSetTimeoutCallback(std::unique_ptr<JSContext> &context,
                              const int callbackId);

void invokeRequestAnimationFrameCallback(JSContext *context, const int callbackId);


} // namespace binding
} // namespace kraken

#endif // BRIDGE_TIMER_H
