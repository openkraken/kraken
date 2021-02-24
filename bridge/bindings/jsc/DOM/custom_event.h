/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CUSTOM_EVENT_H
#define KRAKENBRIDGE_CUSTOM_EVENT_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context_internal.h"
#include <vector>

namespace kraken::binding::jsc {

void bindCustomEvent(std::unique_ptr<JSContext> &context);

class CustomEventInstance;

struct NativeCustomEvent {
  NativeCustomEvent() = delete;
  explicit NativeCustomEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

  NativeEvent *nativeEvent;

  NativeString *detail;
};

class JSCustomEvent : public JSEvent {
public:
  DEFINE_OBJECT_PROPERTY(CustomEvent, 1, detail)
  DEFINE_PROTOTYPE_OBJECT_PROPERTY(CustomEvent, 1, initCustomEvent)

  static std::unordered_map<JSContext *, JSCustomEvent *> instanceMap;
  OBJECT_INSTANCE(JSCustomEvent)

  static JSValueRef initCustomEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                    const JSValueRef arguments[], JSValueRef *exception);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSCustomEvent() = delete;
  explicit JSCustomEvent(JSContext *context);
  ~JSCustomEvent() override;

private:
  JSFunctionHolder m_initCustomEvent{context, prototypeObject, this, "initCustomEvent", initCustomEvent};
  friend CustomEventInstance;
};

class CustomEventInstance : public EventInstance {
public:
  CustomEventInstance() = delete;
  explicit CustomEventInstance(JSCustomEvent *jsCustomEvent, std::string CustomEventType, JSValueRef eventInit, JSValueRef *exception);
  explicit CustomEventInstance(JSCustomEvent *jsCustomEvent, NativeCustomEvent* nativeCustomEvent);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~CustomEventInstance() override;

private:
  friend JSCustomEvent;
  JSValueHolder m_detail{context, nullptr};
  NativeCustomEvent* nativeCustomEvent;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_CUSTOM_EVENT_H
