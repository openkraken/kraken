/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"

#define PROPAGATION_STOPPED 1
#define PROPAGATION_CONTINUE 0

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken {

EventTarget* EventTarget::Create(ExecutingContext* context) {
  return makeGarbageCollected<EventTarget>(context);
}

EventTarget::EventTarget(ExecutingContext* context) : ScriptWrappable(context->ctx()) {}

void EventTarget::Trace(GCVisitor* visitor) const {}

void EventTarget::Dispose() const {}

const char* EventTarget::GetHumanReadableName() const {
  return "EventTarget";
}

}  // namespace kraken

// namespace kraken::binding::qjs
