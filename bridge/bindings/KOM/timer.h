/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef BRIDGE_TIMER_H
#define BRIDGE_TIMER_H

#include "jsa.h"

namespace kraken {
namespace binding {

void bindTimer(alibaba::jsa::JSContext *context);
void unbindTimer();
void invokeSetIntervalCallback(alibaba::jsa::JSContext *context,
                               const int callbackId);
void invokeSetTimeoutCallback(alibaba::jsa::JSContext *context,
                              const int callbackId);

void invokeRequestAnimationFrameCallback(alibaba::jsa::JSContext *context, const int callbackId);


} // namespace binding
} // namespace kraken

#endif // BRIDGE_TIMER_H
