/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_EVENTS_REGISTERED_EVENTLISTENER_H_
#define KRAKENBRIDGE_CORE_DOM_EVENTS_REGISTERED_EVENTLISTENER_H_

#include "bindings/qjs/add_event_listener_options.h"
#include "bindings/qjs/event_listener_options.h"
#include "event_listener.h"
#include "foundation/macros.h"

namespace kraken {

// RegisteredEventListener represents 'event listener' defined in the DOM
// standard. https://dom.spec.whatwg.org/#concept-event-listener
class RegisteredEventListener final {
  KRAKEN_DISALLOW_NEW()
 public:
  RegisteredEventListener();
  RegisteredEventListener(const std::shared_ptr<EventListener>& listener, std::shared_ptr<AddEventListenerOptions> options);
  RegisteredEventListener(const RegisteredEventListener& that);
  RegisteredEventListener& operator=(const RegisteredEventListener& that);

  const std::shared_ptr<EventListener> Callback() const { return callback_; }
  std::shared_ptr<EventListener> Callback() { return callback_; }

  void SetCallback(EventListener* listener);

  bool Passive() const { return passive_; }

  bool Once() const { return once_; }

  bool Capture() const { return use_capture_; }

  bool BlockedEventWarningEmitted() const { return blocked_event_warning_emitted_; }

  void SetBlockedEventWarningEmitted() { blocked_event_warning_emitted_ = true; }

  bool Matches(const std::shared_ptr<EventListener>& listener, const std::shared_ptr<EventListenerOptions>& options) const;

  bool ShouldFire(const Event&) const;

 private:
  std::shared_ptr<EventListener> callback_;
  unsigned use_capture_ : 1;
  unsigned passive_ : 1;
  unsigned once_ : 1;
  unsigned blocked_event_warning_emitted_ : 1;

 private:
};

bool operator==(const RegisteredEventListener&, const RegisteredEventListener&);

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_EVENTS_REGISTERED_EVENTLISTENER_H_
