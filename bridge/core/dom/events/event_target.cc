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

// EventTargetData
EventTargetData::EventTargetData() {}

EventTargetData::~EventTargetData() {}

void EventTargetData::Trace(GCVisitor* visitor) const {}

EventTarget* EventTarget::Create(ExecutingContext* context) {
  return makeGarbageCollected<EventTargetWithInlineData>(context);
}

EventTarget::EventTarget(ExecutingContext* context) : ScriptWrappable(context->ctx()) {}

bool EventTarget::addEventListener(const AtomicString& event_type,
                                   const std::shared_ptr<JSEventListener>& event_listener,
                                   ExceptionState& exception_state) {
  return AddEventListenerInternal(event_type, event_listener.get());
}

bool EventTarget::removeEventListener(const AtomicString& event_type,
                                      const std::shared_ptr<JSEventListener>& event_listener,
                                      ExceptionState& exception_state) {
  return RemoveEventListenerInternal(event_type, event_listener.get());
}

bool EventTarget::dispatchEvent(Event* event, ExceptionState& exception_state) {
  if (!event->WasInitialized()) {
    exception_state.ThrowException(event->ctx(), ErrorType::InternalError,
                                      "The event provided is uninitialized.");
    return false;
  }

  if (event->IsBeingDispatched()) {
    exception_state.ThrowException(event->ctx(), ErrorType::InternalError,
                                      "The event is already being dispatched.");
    return false;
  }

  if (!context())
    return false;

  event->SetTrusted(false);

  // Return whether the event was cancelled or not to JS not that it
  // might have actually been default handled; so check only against
  // CanceledByEventHandler.
  return DispatchEventInternal(*event) !=
      DispatchEventResult::kCanceledByEventHandler;
}

void EventTarget::Trace(GCVisitor* visitor) const {}

void EventTarget::Dispose() const {}

bool EventTarget::AddEventListenerInternal(const AtomicString& event_type, const EventListener* listener) {
  return false;
}

bool EventTarget::RemoveEventListenerInternal(const AtomicString& event_type, const EventListener* listener) {
  return false;
}

DispatchEventResult EventTarget::DispatchEventInternal(Event& event) {
  return DispatchEventResult::kCanceledByDefaultEventHandler;
}

const char* EventTarget::GetHumanReadableName() const {
  return "EventTarget";
}
}  // namespace kraken

// namespace kraken::binding::qjs
