/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CUSTOM_EVENT_H
#define KRAKENBRIDGE_CUSTOM_EVENT_H

#include "event.h"

namespace kraken::binding::qjs {

void bindCustomEvent(std::unique_ptr<JSContext> &context);

struct NativeCustomEvent {
  NativeCustomEvent() = delete;
  explicit NativeCustomEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

  NativeEvent *nativeEvent;
  NativeString *detail{nullptr};
};

class CustomEvent : public Event {
public:
  CustomEvent() = delete;
  explicit CustomEvent(JSContext *context) : Event(context) {};
  JSValue constructor(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) override;

  static JSValue initCustomEvent(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  OBJECT_INSTANCE(CustomEvent);

private:
  DEFINE_OBJECT_PROPERTY(1, detail);

  ObjectFunction m_initCustomEvent{m_context, m_prototypeObject, "initCustomEvent", initCustomEvent, 4};
};

class CustomEventInstance : public EventInstance {
public:
  explicit CustomEventInstance(CustomEvent *jsCustomEvent, std::string CustomEventType, JSValue eventInit);
  explicit CustomEventInstance(CustomEvent *jsCustomEvent, NativeCustomEvent* nativeCustomEvent);
  ~CustomEventInstance() override {
    delete nativeCustomEvent;
  }

  void inline setDetail(JSValue value) {
    m_detail.setValue(value);
  }
  JSValue getDetail() {
    return m_detail.value();
  }

private:
  JSValueHolder m_detail{m_ctx, JS_NULL};
  NativeCustomEvent* nativeCustomEvent{nullptr};
};



}

#endif // KRAKENBRIDGE_CUSTOM_EVENT_H
