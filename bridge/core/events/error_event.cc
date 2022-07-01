/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "error_event.h"

namespace kraken {

ErrorEvent* ErrorEvent::Create(ExecutingContext* context, const std::string& message) {
  return MakeGarbageCollected<ErrorEvent>(context, message);
}
ErrorEvent* ErrorEvent::Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state) {
  return MakeGarbageCollected<ErrorEvent>(context, type, exception_state);
}
ErrorEvent* ErrorEvent::Create(ExecutingContext* context,
                               const AtomicString& type,
                               const std::shared_ptr<ErrorEventInit>& initializer,
                               ExceptionState& exception_state) {
  return MakeGarbageCollected<ErrorEvent>(context, type, initializer, exception_state);
}

ErrorEvent::ErrorEvent(ExecutingContext* context, const std::string& message)
    : Event(context), message_(message), source_location_(std::make_unique<SourceLocation>("", 0, 0)) {}

ErrorEvent::ErrorEvent(ExecutingContext* context, const std::string& message, std::unique_ptr<SourceLocation> location)
    : Event(context), message_(message), source_location_(std::move(location)) {}

ErrorEvent::ErrorEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context), message_(type.ToStdString()), source_location_(std::make_unique<SourceLocation>("", 0, 0)) {}

ErrorEvent::ErrorEvent(ExecutingContext* context,
                       const AtomicString& type,
                       const std::shared_ptr<ErrorEventInit>& initializer,
                       ExceptionState& exception_state)
    : Event(context),
      message_(type.ToStdString()),
      error_(initializer->error()),
      source_location_(std::make_unique<SourceLocation>(initializer->filename().ToStdString(),
                                                        initializer->lineno(),
                                                        initializer->colno())) {}

}  // namespace kraken
