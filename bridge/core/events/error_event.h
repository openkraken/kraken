/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_EVENTS_ERROR_EVENT_H_
#define KRAKENBRIDGE_CORE_DOM_EVENTS_ERROR_EVENT_H_

#include "bindings/qjs/dictionary_base.h"
#include "bindings/qjs/source_location.h"
#include "core/dom/events/event.h"
#include "qjs_error_event_init.h"

namespace kraken {

class ErrorEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();
 public:
  using ImplType = ErrorEvent*;
  static ErrorEvent* Create(ExecutingContext* context, const std::string& message);
  static ErrorEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  static ErrorEvent* Create(ExecutingContext* context, const AtomicString& type, const ErrorEventInit* initializer,  ExceptionState& exception_state);

  explicit ErrorEvent(ExecutingContext* context, const std::string& message);
  explicit ErrorEvent(ExecutingContext* context, const std::string& message, std::unique_ptr<SourceLocation> location);
  explicit ErrorEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  explicit ErrorEvent(ExecutingContext* context, const AtomicString& type, const ErrorEventInit* initializer, ExceptionState& exception_state);

  // As |message| is exposed to JavaScript, never return |unsanitized_message_|.
  const std::string& message() const { return message_; }
  const std::string& filename() const { return source_location_->Url(); }
  unsigned lineno() const { return source_location_->LineNumber(); }
  unsigned colno() const { return source_location_->ColumnNumber(); }

  ScriptValue error() const { return error_; }

  SourceLocation* Location() const { return source_location_.get(); }

 private:
  std::string message_;
  std::unique_ptr<SourceLocation> source_location_{nullptr};
  ScriptValue error_;
};

}

#endif  // KRAKENBRIDGE_CORE_DOM_EVENTS_ERROR_EVENT_H_
