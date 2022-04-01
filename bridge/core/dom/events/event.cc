/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event.h"
#include "core/executing_context.h"
#include "event_target.h"

namespace kraken {

Event* Event::From(ExecutingContext* context, NativeEvent* native_event) {
  AtomicString event_type = AtomicString::From(context->ctx(), native_event->type);

  auto* event = makeGarbageCollected<Event>(context, event_type, native_event->bubbles == 0 ? Bubbles::kNo : Bubbles::kYes, native_event->cancelable == 0 ? Cancelable::kNo : Cancelable::kYes,
                                             ComposedMode::kComposed, native_event->timeStamp);
  event->SetTarget(static_cast<EventTarget*>(native_event->target));
  event->SetCurrentTarget(static_cast<EventTarget*>(native_event->currentTarget));
  event->default_prevented_ = native_event->defaultPrevented;
  return event;
}

Event::Event(ExecutingContext* context) : type_(AtomicString::Empty(context->ctx())), ScriptWrappable(context->ctx()) {}

Event::Event(ExecutingContext* context, const AtomicString& event_type) : type_(event_type), ScriptWrappable(context->ctx()) {}

Event::Event(ExecutingContext* context, const AtomicString& event_type, Bubbles bubbles, Cancelable cancelable, ComposedMode composed_mode, double time_stamp)
    : ScriptWrappable(context->ctx()),
      type_(event_type),
      bubbles_(bubbles == Bubbles::kYes),
      cancelable_(cancelable == Cancelable::kYes),
      composed_(composed_mode == ComposedMode::kComposed),
      propagation_stopped_(false),
      immediate_propagation_stopped_(false),
      default_prevented_(false),
      default_handled_(false),
      was_initialized_(true),
      is_trusted_(false),
      prevent_default_called_on_uncancelable_event_(false),
      fire_only_capture_listeners_at_target_(false),
      fire_only_non_capture_listeners_at_target_(false),
      event_phase_(0),
      current_target_(nullptr),
      time_stamp_(time_stamp) {}

const char* Event::GetHumanReadableName() const {
  return "Event";
}

void Event::SetType(const AtomicString& type) {
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

void Event::initEvent(const AtomicString& event_type, bool bubbles, bool cancelable, ExceptionState& exception_state) {
  if (IsBeingDispatched()) {
    return;
  }

  was_initialized_ = true;
  propagation_stopped_ = false;
  immediate_propagation_stopped_ = false;
  default_prevented_ = false;

  type_ = event_type;
  bubbles_ = bubbles;
  cancelable_ = cancelable;
}

void Event::Trace(GCVisitor* visitor) const {
  visitor->Trace(target_);
  visitor->Trace(current_target_);
}
void Event::Dispose() const {}

}  // namespace kraken
