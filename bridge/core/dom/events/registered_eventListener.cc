/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "registered_eventListener.h"

namespace kraken {

RegisteredEventListener::RegisteredEventListener()
    : use_capture_(false), passive_(false), once_(false), blocked_event_warning_emitted_(false){}

RegisteredEventListener::RegisteredEventListener(const std::shared_ptr<EventListener>& listener, std::shared_ptr<AddEventListenerOptions> options)
    : callback_(listener),
      use_capture_(options->capture()),
      passive_(options->passive()),
      once_(options->once()),
      blocked_event_warning_emitted_(false) {
      };

RegisteredEventListener::RegisteredEventListener(const RegisteredEventListener& that) = default;

RegisteredEventListener& RegisteredEventListener::operator=(const RegisteredEventListener& that) = default;

void RegisteredEventListener::SetCallback(EventListener* listener) {}

bool RegisteredEventListener::Matches(const std::shared_ptr<EventListener>& listener, const std::shared_ptr<EventListenerOptions>& options) const {
  // Equality is soley based on the listener and useCapture flags.
  assert(callback_);
  assert(listener);
  return callback_->Matches(*listener) && static_cast<bool>(use_capture_) == options->capture();
}

bool RegisteredEventListener::ShouldFire(const Event& event) const {
  if (event.FireOnlyCaptureListenersAtTarget()) {
    assert(event.eventPhase() == Event::kAtTarget);
    return Capture();
  }
  if (event.FireOnlyNonCaptureListenersAtTarget()) {
    assert(event.eventPhase() == Event::kAtTarget);
    return !Capture();
  }
  if (event.eventPhase() == Event::kCapturingPhase)
    return Capture();
  if (event.eventPhase() == Event::kBubblingPhase)
    return !Capture();
  return true;
}

bool operator==(const RegisteredEventListener& lhs, const RegisteredEventListener& rhs) {
  assert(lhs.Callback());
  assert(rhs.Callback());
  return lhs.Callback()->Matches(*rhs.Callback()) && lhs.Capture() == rhs.Capture();
}

}  // namespace kraken
