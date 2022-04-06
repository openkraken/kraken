/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"
#include "bindings/qjs/converter_impl.h"
#include "event_type_names.h"
#include "qjs_add_event_listener_options.h"

#define PROPAGATION_STOPPED 1
#define PROPAGATION_CONTINUE 0

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken {

Event::PassiveMode EventPassiveMode(const RegisteredEventListener& event_listener) {
  if (!event_listener.Passive()) {
    return Event::PassiveMode::kNotPassiveDefault;
  }
  return Event::PassiveMode::kPassiveDefault;
}

// EventTargetData
EventTargetData::EventTargetData() {}

EventTargetData::~EventTargetData() {}

void EventTargetData::Trace(GCVisitor* visitor) const {}

EventTarget* EventTarget::Create(ExecutingContext* context) {
  return makeGarbageCollected<EventTargetWithInlineData>(context);
}

EventTarget::EventTarget(ExecutingContext* context) : ScriptWrappable(context->ctx()) {}

bool EventTarget::addEventListener(const AtomicString& event_type,
                                   const std::shared_ptr<EventListener>& event_listener,
                                   const std::shared_ptr<AddEventListenerOptions>& options,
                                   ExceptionState& exception_state) {
  return AddEventListenerInternal(event_type, event_listener, options);
}

bool EventTarget::addEventListener(const AtomicString& event_type,
                                   const std::shared_ptr<EventListener>& event_listener,
                                   ExceptionState& exception_state) {
  std::shared_ptr<AddEventListenerOptions> options = AddEventListenerOptions::Create();
  return AddEventListenerInternal(event_type, event_listener, options);
}

bool EventTarget::removeEventListener(const AtomicString& event_type,
                                      const std::shared_ptr<EventListener>& event_listener,
                                      ExceptionState& exception_state) {
  std::shared_ptr<EventListenerOptions> options = EventListenerOptions::Create();
  return RemoveEventListenerInternal(event_type, event_listener, options);
}

bool EventTarget::removeEventListener(const AtomicString& event_type,
                                      const std::shared_ptr<EventListener>& event_listener,
                                      const std::shared_ptr<EventListenerOptions>& options,
                                      ExceptionState& exception_state) {
  return RemoveEventListenerInternal(event_type, event_listener, options);
}

bool EventTarget::removeEventListener(const AtomicString& event_type,
                                      const std::shared_ptr<EventListener>& event_listener,
                                      bool use_capture,
                                      ExceptionState& exception_state) {
  auto options = EventListenerOptions::Create();
  options->setCapture(use_capture);
  return RemoveEventListenerInternal(event_type, event_listener, options);
}

bool EventTarget::dispatchEvent(Event* event, ExceptionState& exception_state) {
  if (!event->WasInitialized()) {
    exception_state.ThrowException(event->ctx(), ErrorType::InternalError, "The event provided is uninitialized.");
    return false;
  }

  if (event->IsBeingDispatched()) {
    exception_state.ThrowException(event->ctx(), ErrorType::InternalError, "The event is already being dispatched.");
    return false;
  }

  if (!GetExecutingContext())
    return false;

  event->SetTrusted(false);

  // Return whether the event was cancelled or not to JS not that it
  // might have actually been default handled; so check only against
  // CanceledByEventHandler.
  return DispatchEventInternal(*event) != DispatchEventResult::kCanceledByEventHandler;
}

void EventTarget::Trace(GCVisitor* visitor) const {}

void EventTarget::Dispose() const {}

DispatchEventResult EventTarget::FireEventListeners(Event& event, ExceptionState& exception_state) {
  assert(event.WasInitialized());

  EventTargetData* d = GetEventTargetData();
  if (!d)
    return DispatchEventResult::kNotCanceled;

  EventListenerVector* listeners_vector = d->event_listener_map.Find(event.type());

  bool fired_event_listeners = false;
  if (listeners_vector) {
    fired_event_listeners = FireEventListeners(event, d, *listeners_vector, exception_state);
  }

  // Only invoke the callback if event listeners were fired for this phase.
  if (fired_event_listeners) {
    event.DoneDispatchingEventAtCurrentTarget();
  }
  return GetDispatchEventResult(event);
}

DispatchEventResult EventTarget::GetDispatchEventResult(const Event& event) {
  if (event.defaultPrevented())
    return DispatchEventResult::kCanceledByEventHandler;
  if (event.DefaultHandled())
    return DispatchEventResult::kCanceledByDefaultEventHandler;
  return DispatchEventResult::kNotCanceled;
}

bool EventTarget::AddEventListenerInternal(const AtomicString& event_type,
                                           const std::shared_ptr<EventListener>& listener,
                                           const std::shared_ptr<AddEventListenerOptions>& options) {
  if (!listener)
    return false;

  RegisteredEventListener registered_listener;
  bool added = EnsureEventTargetData().event_listener_map.Add(event_type, listener, options, &registered_listener);

  return added;
}

bool EventTarget::RemoveEventListenerInternal(const AtomicString& event_type,
                                              const std::shared_ptr<EventListener>& listener,
                                              const std::shared_ptr<EventListenerOptions>& options) {
  if (!listener)
    return false;

  EventTargetData* d = GetEventTargetData();
  if (!d)
    return false;

  size_t index_of_removed_listener;
  RegisteredEventListener registered_listener;

  if (!d->event_listener_map.Remove(event_type, listener, options, &index_of_removed_listener, &registered_listener))
    return false;

  // Notify firing events planning to invoke the listener at 'index' that
  // they have one less listener to invoke.
  if (d->firing_event_iterators) {
    for (const auto& firing_iterator : *d->firing_event_iterators) {
      if (event_type != firing_iterator.event_type)
        continue;

      if (index_of_removed_listener >= firing_iterator.end)
        continue;

      --firing_iterator.end;
      // Note that when firing an event listener,
      // firingIterator.iterator indicates the next event listener
      // that would fire, not the currently firing event
      // listener. See EventTarget::fireEventListeners.
      if (index_of_removed_listener < firing_iterator.iterator)
        --firing_iterator.iterator;
    }
  }

  return true;
}

DispatchEventResult EventTarget::DispatchEventInternal(Event& event) {
  return DispatchEventResult::kCanceledByDefaultEventHandler;
}

const char* EventTarget::GetHumanReadableName() const {
  return "EventTarget";
}

bool EventTarget::FireEventListeners(Event& event,
                                     EventTargetData* d,
                                     EventListenerVector& entry,
                                     ExceptionState& exception_state) {
  // Fire all listeners registered for this event. Don't fire listeners removed
  // during event dispatch. Also, don't fire event listeners added during event
  // dispatch. Conveniently, all new event listeners will be added after or at
  // index |size|, so iterating up to (but not including) |size| naturally
  // excludes new event listeners.
  ExecutingContext* context = GetExecutingContext();
  if (!context)
    return false;

  size_t i = 0;
  size_t size = entry.size();
  if (!d->firing_event_iterators)
    d->firing_event_iterators = std::make_unique<FiringEventIteratorVector>();
  d->firing_event_iterators->push_back(FiringEventIterator(event.type(), i, size));

  bool fired_listener = false;

  while (i < size) {
    // If stopImmediatePropagation has been called, we just break out
    // immediately, without handling any more events on this target.
    if (event.ImmediatePropagationStopped())
      break;

    RegisteredEventListener registered_listener = entry[i];

    // Move the iterator past this event listener. This must match
    // the handling of the FiringEventIterator::iterator in
    // EventTarget::removeEventListener.
    ++i;

    if (!registered_listener.ShouldFire(event))
      continue;

    std::shared_ptr<EventListener> listener = registered_listener.Callback();
    // The listener will be retained by Member<EventListener> in the
    // registeredListener, i and size are updated with the firing event iterator
    // in case the listener is removed from the listener vector below.
    if (registered_listener.Once())
      removeEventListener(event.type(), listener, registered_listener.Capture(), exception_state);

    event.SetHandlingPassive(EventPassiveMode(registered_listener));

    // To match Mozilla, the AT_TARGET phase fires both capturing and bubbling
    // event listeners, even though that violates some versions of the DOM spec.
    listener->Invoke(context, &event, exception_state);
    fired_listener = true;

    event.SetHandlingPassive(Event::PassiveMode::kNotPassive);

    assert(i < size);
  }
  d->firing_event_iterators->pop_back();
  return fired_listener;
}

void EventTargetWithInlineData::Trace(GCVisitor* visitor) const {
  EventTarget::Trace(visitor);
}

}  // namespace kraken

// namespace kraken::binding::qjs
