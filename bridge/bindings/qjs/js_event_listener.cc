/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "js_event_listener.h"
#include "core/dom/events/event_target.h"

namespace kraken {

JSEventListener::JSEventListener(std::shared_ptr<QJSFunction> listener) : event_listener_(listener) {}
JSValue JSEventListener::GetListenerObject(EventTarget&) {
  return event_listener_->ToQuickJS();
}
JSValue JSEventListener::GetEffectiveFunction(EventTarget&) {
  return event_listener_->ToQuickJS();
}
void JSEventListener::InvokeInternal(EventTarget& event_target, Event& event, ExceptionState& exception_state) {
  ScriptValue arguments[] = {
    event.ToValue()
  };

  ScriptValue result =
      event_listener_->Invoke(event.ctx(), event_target.ToValue(), 1, arguments);
  if (result.IsException()) {
    exception_state.ThrowException(event.ctx(), result.QJSValue());
    return;
  }
}

void JSEventListener::Trace(GCVisitor* visitor) const {
  event_listener_->Trace(visitor);
}

}  // namespace kraken
