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

  auto* event =
      MakeGarbageCollected<Event>(context, event_type, native_event->bubbles == 0 ? Bubbles::kNo : Bubbles::kYes,
                                  native_event->cancelable == 0 ? Cancelable::kNo : Cancelable::kYes,
                                  ComposedMode::kComposed, native_event->timeStamp);
  event->SetTarget(static_cast<EventTarget*>(native_event->target));
  event->SetCurrentTarget(static_cast<EventTarget*>(native_event->currentTarget));
  event->default_prevented_ = native_event->defaultPrevented;
  return event;
}

Event::Event(ExecutingContext* context) : Event(context, AtomicString::Empty(context->ctx())) {}

Event::Event(ExecutingContext* context, const AtomicString& event_type)
    : Event(context,
            event_type,
            Bubbles::kNo,
            Cancelable::kNo,
            ComposedMode::kComposed,
            std::chrono::system_clock::now().time_since_epoch().count()) {}

Event::Event(ExecutingContext* context, const AtomicString& type, const std::shared_ptr<EventInit>& init)
    : ScriptWrappable(context->ctx()),
      type_(type),
      bubbles_(init->bubbles()),
      cancelable_(init->cancelable()),
      composed_(init->composed()) {}

Event::Event(ExecutingContext* context,
             const AtomicString& event_type,
             Bubbles bubbles,
             Cancelable cancelable,
             ComposedMode composed_mode,
             double time_stamp)
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
      handling_passive_(PassiveMode::kNotPassiveDefault),
      prevent_default_called_on_uncancelable_event_(false),
      fire_only_capture_listeners_at_target_(false),
      fire_only_non_capture_listeners_at_target_(false),
      event_phase_(0),
      current_target_(nullptr),
      time_stamp_(time_stamp) {}

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

bool Event::IsUIEvent() const {
  return false;
}

bool Event::IsMouseEvent() const {
  return false;
}

bool Event::IsFocusEvent() const {
  return false;
}

bool Event::IsKeyboardEvent() const {
  return false;
}

bool Event::IsTouchEvent() const {
  return false;
}

bool Event::IsGestureEvent() const {
  return false;
}

bool Event::IsPointerEvent() const {
  return false;
}

bool Event::IsInputEvent() const {
  return false;
}

bool Event::IsDragEvent() const {
  return false;
}

bool Event::IsBeforeUnloadEvent() const {
  return false;
}

bool Event::IsErrorEvent() const {
  return false;
}

void Event::preventDefault(ExceptionState& exception_state) {
  if (handling_passive_ != PassiveMode::kNotPassive && handling_passive_ != PassiveMode::kNotPassiveDefault) {
    return;
  }

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

void Event::SetHandlingPassive(PassiveMode mode) {
  handling_passive_ = mode;
}

void Event::Trace(GCVisitor* visitor) const {}

}  // namespace kraken
