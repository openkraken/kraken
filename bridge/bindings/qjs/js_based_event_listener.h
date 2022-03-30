/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_JS_BASED_EVENT_LISTENER_H_
#define KRAKENBRIDGE_BINDINGS_QJS_JS_BASED_EVENT_LISTENER_H_

#include <quickjs/quickjs.h>
#include "core/dom/events/event_listener.h"
#include "core/executing_context.h"

namespace kraken {

// |JSBasedEventListener| is the base class for JS-based event listeners,
// i.e. EventListener and EventHandler in the standards.
// This provides the essential APIs of JS-based event listeners and also
// implements the common features.
class JSBasedEventListener : public EventListener {
 public:
  // Implements step 2. of "inner invoke".
  // See: https://dom.spec.whatwg.org/#concept-event-listener-inner-invoke
  void Invoke(ExecutingContext* context, Event* event) final;
  // Returns Functions that handles invoked event or undefined without
  // throwing any exception.
  virtual JSValue GetEffectiveFunction(EventTarget&) = 0;

  virtual bool IsJSEventListener() const { return false; }
  virtual bool IsJSEventHandler() const { return false; }

 protected:
  JSBasedEventListener();

 private:
  // Performs "call a user object's operation", required in "inner-invoke".
  // "The event handler processing algorithm" corresponds to this in the case of
  // EventHandler.
  // This may throw an exception on invoking the listener.
  // See step 2-10:
  // https://dom.spec.whatwg.org/#concept-event-listener-inner-invoke
  virtual void InvokeInternal(EventTarget&,
                              Event&,
                              ExceptionState& exception_state) = 0;
};


}

#endif  // KRAKENBRIDGE_BINDINGS_QJS_JS_BASED_EVENT_LISTENER_H_
