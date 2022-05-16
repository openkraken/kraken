/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_EVENTS_MESSAGE_EVENT_H_
#define KRAKENBRIDGE_CORE_EVENTS_MESSAGE_EVENT_H_

#include "core/dom/events/event.h"
#include "qjs_message_event_init.h"

namespace kraken {

class MessageEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = MessageEvent*;

  static MessageEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  static MessageEvent* Create(ExecutingContext* context,
                              const AtomicString& type,
                              const std::shared_ptr<MessageEventInit>& init,
                              ExceptionState& exception_state);

  explicit MessageEvent(ExecutingContext* context, const AtomicString& type);
  explicit MessageEvent(ExecutingContext* context,
                        const AtomicString& type,
                        const std::shared_ptr<MessageEventInit>& init);

  ScriptValue data() const;
  AtomicString origin() const;
  AtomicString lastEventId() const;
  AtomicString source() const;

 private:
  ScriptValue data_;
  AtomicString origin_;
  AtomicString lastEventId_;
  AtomicString source_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_EVENTS_MESSAGE_EVENT_H_
