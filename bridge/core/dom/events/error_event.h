/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_EVENTS_ERROR_EVENT_H_
#define KRAKENBRIDGE_CORE_DOM_EVENTS_ERROR_EVENT_H_

#include "event.h"
#include "bindings/qjs/dictionary_base.h"

namespace kraken {

class ErrorEventInit : public DictionaryBase {
 public:
  static std::shared_ptr<ErrorEventInit> Create(JSContext* ctx, JSValue value, ExceptionState& exception_state) {

  };

  ErrorEventInit() = delete;
  ErrorEventInit(JSContext* ctx, JSValue value, ExceptionState& exception_state);

  bool FillQJSObjectWithMembers(JSContext *ctx, JSValue qjs_dictionary) const override;
  void FillMembersWithQJSObject(JSContext* ctx, JSValue value, ExceptionState& exception_state);
};

class ErrorEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();
 public:
  static ErrorEvent* Create(ExecutingContext* context, const AtomicString& event_type, ExceptionState& exception_state);
 private:

};

}

#endif  // KRAKENBRIDGE_CORE_DOM_EVENTS_ERROR_EVENT_H_
