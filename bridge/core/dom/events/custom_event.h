/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CUSTOM_EVENT_H
#define KRAKENBRIDGE_CUSTOM_EVENT_H

#include "event.h"

namespace kraken {

void bindCustomEvent(ExecutionContext* context);

struct NativeCustomEvent {
  NativeEvent nativeEvent;
  NativeString* detail{nullptr};
};

class CustomEvent : public Event {
 public:
  static JSClassID classId;
  static CustomEvent* create(JSContext* ctx, JSValue eventType, JSValue init);
  static CustomEvent* create(JSContext* ctx, NativeCustomEvent* nativeCustomEvent);
  static JSValue constructor(ExecutionContext* context);
  static JSValue prototype(ExecutionContext* context);

  CustomEvent(JSValue eventType, JSValue init);
  CustomEvent(NativeCustomEvent* nativeEvent);

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;

  DEFINE_FUNCTION(initCustomEvent);

  DEFINE_PROTOTYPE_READONLY_PROPERTY(detail);

 private:
  NativeCustomEvent* m_nativeCustomEvent{nullptr};
  JSValue m_detail{JS_NULL};
};

// class CustomEventInstance : public EventInstance {
// public:
//  explicit CustomEventInstance(CustomEvent* jsCustomEvent, JSAtom CustomEventType, JSValue eventInit);
//  explicit CustomEventInstance(CustomEvent* jsCustomEvent, NativeCustomEvent* nativeCustomEvent);
//
// private:

//  NativeCustomEvent* nativeCustomEvent{nullptr};
//  friend CustomEvent;
//};

auto customEventCreator = [](JSContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags) -> JSValue {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to construct 'CustomEvent': 1 argument required, but only 0 present.");
  }

  JSValue typeValue = argv[0];
  JSValue customEventInit = JS_NULL;

  if (argc == 2) {
    customEventInit = argv[1];
  }

  auto* customEvent = CustomEvent::create(ctx, typeValue, customEventInit);
  //  auto* customEvent = new CustomEventInstance(CustomEvent::instance(context()), typeAtom, customEventInit);
  //  JS_FreeAtom(m_ctx, typeAtom);
  return customEvent->toQuickJS();
};

const WrapperTypeInfo customEventTypeInfo = {"CustomEvent", &eventTypeInfo, customEventCreator};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CUSTOM_EVENT_H
