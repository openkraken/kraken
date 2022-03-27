/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_ADD_EVENT_LISTENER_OPTIONS_H_
#define KRAKENBRIDGE_BINDINGS_QJS_ADD_EVENT_LISTENER_OPTIONS_H_

#include "dictionary_base.h"
#include "event_listener_options.h"

namespace kraken {

class AddEventListenerOptions : public EventListenerOptions {
 public:
  static std::unique_ptr<AddEventListenerOptions> Create(JSContext* ctx, JSValue dictionary_value, ExecutingContext& executing_context) {}

  explicit AddEventListenerOptions();
  explicit AddEventListenerOptions(JSContext* ctx, JSValue dictionary_value, ExecutingContext& executing_context);

  bool hasOnce() const { return true; }
  bool once() const { return member_once_; }
  void setOnce(bool value) { member_once_ = value; }

  bool hasPassive() const { return has_passive_; }
  bool passive() const { return member_passive_; }
  bool getPassiveOr(bool fallback_value) const {
    if (!hasPassive()) {
      return fallback_value;
    }
    return member_passive_;
  }
  void setPassive(bool value) {
    member_passive_ = value;
    has_passive_ = true;
  }

 protected:
  bool FillQJSObjectWithMembers(JSContext* ctx, JSValue qjs_dictionary) const override;

 private:
  void FillMembersFromQJSObject(JSContext* ctx, JSValue qjs_dictionary);

  bool has_passive_ = false;
  bool member_once_{false};
  bool member_passive_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_ADD_EVENT_LISTENER_OPTIONS_H_
