/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_EVENTS_EVENT_TARGET_IMPL_H_
#define KRAKENBRIDGE_CORE_DOM_EVENTS_EVENT_TARGET_IMPL_H_

#include "event_target.h"

namespace kraken {

// Constructible version of EventTarget. Calls to EventTarget
// constructor in JavaScript will return an instance of this class.
// We don't use EventTarget directly because EventTarget is an abstract
// class and and making it non-abstract is unfavorable  because it will
// increase the size of EventTarget and all of its subclasses with code
// that are mostly unnecessary for them, resulting in a performance
// decrease.
class EventTargetImpl : public EventTarget {};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_EVENTS_EVENT_TARGET_IMPL_H_
