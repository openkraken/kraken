/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CUSTOM_EVENT_H
#define KRAKENBRIDGE_CUSTOM_EVENT_H

#include "event.h"

namespace kraken::binding::qjs {

void bindCustomEvent(std::unique_ptr<JSContext>& context);

struct NativeCustomEvent {
  NativeEvent nativeEvent;
  NativeString* detail{nullptr};
};

class CustomEventInstance;

class CustomEvent : public Event {
 public:
  CustomEvent() = delete;
  explicit CustomEvent(JSContext* context) : Event(context) { JS_SetPrototype(m_ctx, m_prototypeObject, Event::instance(m_context)->prototype()); };
  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  static JSValue initCustomEvent(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  OBJECT_INSTANCE(CustomEvent);

 private:
  DEFINE_PROTOTYPE_READONLY_PROPERTY(detail);

  DEFINE_PROTOTYPE_FUNCTION(initCustomEvent, 4);
  friend CustomEventInstance;
};

class CustomEventInstance : public EventInstance {
 public:
  explicit CustomEventInstance(CustomEvent* jsCustomEvent, JSAtom CustomEventType, JSValue eventInit);
  explicit CustomEventInstance(CustomEvent* jsCustomEvent, NativeCustomEvent* nativeCustomEvent);

 private:
  JSValueHolder m_detail{m_ctx, JS_NULL};
  NativeCustomEvent* nativeCustomEvent{nullptr};
  friend CustomEvent;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_CUSTOM_EVENT_H
