/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "add_event_listener_options.h"

namespace kraken {

AddEventListenerOptions::AddEventListenerOptions() {}

AddEventListenerOptions::AddEventListenerOptions(JSContext* ctx, JSValue dictionary_value, ExceptionState& exception_state) {}

bool AddEventListenerOptions::FillQJSObjectWithMembers(JSContext* ctx, JSValue qjs_dictionary) const {
  if (!JS_IsObject(qjs_dictionary)) {
    return false;
  }

  JS_SetPropertyStr(ctx, qjs_dictionary, "passive", JS_NewBool(ctx, member_passive_));
  JS_SetPropertyStr(ctx, qjs_dictionary, "once", JS_NewBool(ctx, member_once_));

  EventListenerOptions::FillQJSObjectWithMembers(ctx, qjs_dictionary);

  return true;
}

void AddEventListenerOptions::FillMembersFromQJSObject(JSContext* ctx, JSValue qjs_dictionary) {
  if (!JS_IsObject(qjs_dictionary)) {
    return;
  }

  JSValue passive = JS_GetPropertyStr(ctx, qjs_dictionary, "passive");
  member_passive_ = JS_ToBool(ctx, passive);
  JS_FreeValue(ctx, passive);

  JSValue once = JS_GetPropertyStr(ctx, qjs_dictionary, "once");
  member_once_ = JS_ToBool(ctx, once);
  JS_FreeValue(ctx, once);
}

}  // namespace kraken
