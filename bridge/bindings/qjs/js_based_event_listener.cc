/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "js_based_event_listener.h"

namespace kraken {

// Implements step 2. of "inner invoke".
// https://dom.spec.whatwg.org/#concept-event-listener-inner-invoke
void JSBasedEventListener::Invoke(ExecutingContext* context, Event* event) {
  assert(context);
  assert(event);

  if (!context->IsValid()) return;

  ExceptionState exception_state;
  // Step 10: Call a listener with event's currentTarget as receiver and event
  // and handle errors if thrown.
  InvokeInternal(*event->currentTarget(), *event, exception_state);
}

}
