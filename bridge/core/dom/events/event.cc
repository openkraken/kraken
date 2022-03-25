/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event.h"
#include "core/executing_context.h"

namespace kraken {

Event::Event(ExecutingContext* context) : ScriptWrappable(context->ctx()) {}

Event::Event(ExecutingContext* context, NativeEvent* native_event)
    : ScriptWrappable(context->ctx()),
#if ANDROID_32_BIT
      type_(reinterpret_cast<NativeString*>(nativeEvent->type)),
      target_(reinterpret_cast<EventTarget*>(native_event->target)),
      current_target_(reinterpret_cast<EventTarget*>(native_event->currentTarget)),
#else
      type_(native_event->type),
      target_(static_cast<EventTarget*>(native_event->target)),
      current_target_(static_cast<EventTarget*>(native_event->currentTarget)),
#endif
      bubbles_(native_event->bubbles),
      cancelable_(native_event->cancelable),
      time_stamp_(static_cast<double>(native_event->timeStamp)),
      default_prevented_(native_event->defaultPrevented) {
}

void Event::Trace(GCVisitor* visitor) const {}
void Event::Dispose() const {}

const char* Event::GetHumanReadableName() const {
  return "Event";
}

void Event::SetType(NativeString* type) {
  type_ = type;
}

EventTarget* Event::target() const {
  return target_;
}

void Event::SetTarget(EventTarget* target) {
  target_ = target;
}

EventTarget* Event::currentTarget() const {
  return current_target_;
}

EventTarget* Event::srcElement() const {
  return target();
}

void Event::SetCurrentTarget(EventTarget* target) {
  current_target_ = target;
}

void Event::preventDefault(ExceptionState& exception_state) {
  default_prevented_ = true;
}

}  // namespace kraken
