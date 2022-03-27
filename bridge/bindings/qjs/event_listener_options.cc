/*
* Copyright (C) 2021 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include "event_listener_options.h"

namespace kraken {

EventListenerOptions::EventListenerOptions() {}

EventListenerOptions::EventListenerOptions(JSContext* ctx, JSValue value, ExceptionState& exception_state) {
  FillMembersFromQJSObject(ctx, value, exception_state);
}

bool EventListenerOptions::FillQJSObjectWithMembers(JSContext* ctx, JSValue qjs_dictionary) const {
  if (!JS_IsObject(qjs_dictionary)) {
    return false;
  }

  JS_SetPropertyStr(ctx, qjs_dictionary, "capture", JS_NewBool(ctx, capture_));

  return true;
}

void EventListenerOptions::FillMembersFromQJSObject(JSContext* ctx, JSValue qjs_dictionary, ExceptionState& exception_state) {
  if (!JS_IsObject(qjs_dictionary)) {
    return;
  }

  JSValue capture = JS_GetPropertyStr(ctx, qjs_dictionary, "capture");
  capture_ = JS_ToBool(ctx, capture);
  JS_FreeValue(ctx, capture);
}

}
