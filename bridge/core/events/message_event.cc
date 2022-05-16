/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "message_event.h"

namespace kraken {

MessageEvent* MessageEvent::Create(ExecutingContext* context,
                                   const AtomicString& type,
                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<MessageEvent>(context, type);
}

MessageEvent* MessageEvent::Create(ExecutingContext* context,
                                   const AtomicString& type,
                                   const std::shared_ptr<MessageEventInit>& init,
                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<MessageEvent>(context, type, init);
}

MessageEvent::MessageEvent(ExecutingContext* context, const AtomicString& type) : Event(context) {}

MessageEvent::MessageEvent(ExecutingContext* context,
                           const AtomicString& type,
                           const std::shared_ptr<MessageEventInit>& init)
    : Event(context),
      data_(init->data()),
      origin_(init->origin()),
      lastEventId_(init->lastEventId()),
      source_(init->source()) {}

ScriptValue MessageEvent::data() const {
  return data_;
}

AtomicString MessageEvent::origin() const {
  return origin_;
}

AtomicString MessageEvent::lastEventId() const {
  return lastEventId_;
}

AtomicString MessageEvent::source() const {
  return source_;
}

}  // namespace kraken
