/*
* Copyright (C) 2021 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#ifndef KRAKENBRIDGE_CORE_DOM_EVENTS_EVENT_LISTENER_OPTIONS_H_
#define KRAKENBRIDGE_CORE_DOM_EVENTS_EVENT_LISTENER_OPTIONS_H_

#include "bindings/qjs/dictionary_base.h"
#include "bindings/qjs/exception_state.h"

namespace kraken {

class EventListenerOptions : public DictionaryBase {
 public:
  static std::shared_ptr<EventListenerOptions> Create(JSContext* ctx,
                                      JSValue value,
                                      ExceptionState& exception_state) {
      return std::make_shared<EventListenerOptions>();
  };
  explicit EventListenerOptions();
  explicit EventListenerOptions(JSContext* ctx, JSValue value, ExceptionState& exception_state);

  bool hasCapture() const { return true; }
  bool capture() const { return capture_; }
  void setCapture(bool value) { capture_ = value; }

 protected:
  bool FillQJSObjectWithMembers(JSContext *ctx, JSValue qjs_dictionary) const override;
 private:
  bool capture_{false};
  void FillMembersFromQJSObject(JSContext* ctx, JSValue qjs_dictionary, ExceptionState& exception_state);
};

}

#endif  // KRAKENBRIDGE_CORE_DOM_EVENTS_EVENT_LISTENER_OPTIONS_H_
