/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_H
#define KRAKENBRIDGE_EVENT_H

#include "bindings/qjs/host_class.h"

namespace kraken::binding::qjs {

//class JSEvent : public HostClass {
//public:
//  DEFINE_OBJECT_PROPERTY(Event, 10, type, bubbles, cancelable, timestamp, defaultPrevented, target, srcElement,
//                         currentTarget, returnValue, cancelBubble)
//  DEFINE_PROTOTYPE_OBJECT_PROPERTY(Event, 4, stopImmediatePropagation, stopPropagation, preventDefault, initEvent)
//
//  static std::unordered_map<JSContext *, JSEvent *> instanceMap;
//  static std::unordered_map<std::string, EventCreator> eventCreatorMap;
//  OBJECT_INSTANCE(JSEvent)
//  // Create an Event Object from an nativeEvent address which allocated by dart side.
//  static JSValueRef initWithNativeEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
//                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
//
//  static JSValueRef stopPropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
//                                    size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
//
//  static JSValueRef initEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
//                              size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
//
//  static JSValueRef stopImmediatePropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
//                                             size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
//
//  static JSValueRef preventDefault(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                                   const JSValueRef arguments[], JSValueRef *exception);
//
//  static EventInstance *buildEventInstance(std::string &eventType, JSContext *context, void *nativeEvent,
//                                           bool isCustomEvent);
//
//  static void defineEvent(std::string eventType, EventCreator creator);
//
//  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
//                                  const JSValueRef *arguments, JSValueRef *exception) override;
//
//  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
//
//protected:
//  JSEvent() = delete;
//  explicit JSEvent(JSContext *context, const char *name);
//  explicit JSEvent(JSContext *context);
//  ~JSEvent() override;
//
//private:
//  friend EventInstance;
//  JSFunctionHolder m_initWithNativeEvent{context, classObject, this, "__initWithNativeEvent__", initWithNativeEvent};
//  JSFunctionHolder m_stopImmediatePropagation{context, prototypeObject, this, "stopImmediatePropagation",
//                                              stopImmediatePropagation};
//  JSFunctionHolder m_stopPropagation{context, prototypeObject, this, "stopPropagation", stopPropagation};
//  JSFunctionHolder m_initEvent{context, prototypeObject, this, "initEvent", initEvent};
//  JSFunctionHolder m_preventDefault{context, prototypeObject, this, "preventDefault", preventDefault};
//};
//
//class EventInstance : public HostClass::Instance {
//public:
//  EventInstance() = delete;
//
//  explicit EventInstance(JSEvent *jsEvent, NativeEvent *nativeEvent);
//  explicit EventInstance(JSEvent *jsEvent, std::string eventType, JSValueRef eventInit, JSValueRef *exception);
//  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
//  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
//  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
//  ~EventInstance() override;
//  NativeEvent *nativeEvent;
//  bool _cancelled{false};
//  bool _propagationStopped{false};
//  bool _propagationImmediatelyStopped{false};
//
//private:
//  friend JSEvent;
//};

class EventInstance;

using EventCreator = EventInstance *(*)(JSContext *context, void *nativeEvent);

class Event : public HostClass {
public:
  JSValue constructor(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) override;
  Event() = delete;
  explicit Event(JSContext *context): HostClass(context, "Event") {}

  static EventInstance *buildEventInstance(std::string &eventType, JSContext *context, void *nativeEvent,
                                           bool isCustomEvent);

private:
  static std::unordered_map<std::string, EventCreator> m_eventCreatorMap;
  OBJECT_INSTANCE(Event);
  DEFINE_OBJECT_PROPERTY(10, Type, Bubbles, Cancelable, Timestamp, DefaultPrevented, Target, SrcElement, CurrentTarget, ReturnValue, CancelBubble)
};

struct NativeEvent {
  NativeEvent() = delete;
  explicit NativeEvent(NativeString *eventType) : type(eventType){};
  NativeString *type;
  int64_t bubbles{0};
  int64_t cancelable{0};
  int64_t timeStamp{0};
  int64_t defaultPrevented{0};
  // The pointer address of target EventTargetInstance object.
  void *target{nullptr};
  // The pointer address of current target EventTargetInstance object.
  void *currentTarget{nullptr};
};

class EventInstance : public Instance {
public:
  EventInstance() = delete;
  explicit EventInstance(Event *event, NativeEvent *nativeEvent);
  explicit EventInstance(Event *jsEvent, std::string eventType, JSValue eventInit);
  ~EventInstance() override {
    delete nativeEvent;
  }

  NativeEvent *nativeEvent{nullptr};

  inline const bool propagationStopped() { return m_propagationStopped; }
  inline const bool cancelled() { return m_cancelled; }
  inline void cancelled(bool v) { m_cancelled = v; }
  inline const bool propagationImmediatelyStopped() { return m_propagationImmediatelyStopped; }
protected:
  bool m_cancelled{false};
  bool m_propagationStopped{false};
  bool m_propagationImmediatelyStopped{false};
};

}

#endif // KRAKENBRIDGE_EVENT_H
