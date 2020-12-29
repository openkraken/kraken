/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_H
#define KRAKENBRIDGE_EVENT_H

#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context.h"
#include <array>
#include <unordered_map>

#define EVENT_CLICK "click"
#define EVENT_INPUT "input"
#define EVENT_APPEAR "appear"
#define EVENT_DISAPPEAR "disappear"
#define EVENT_COLOR_SCHEME_CHANGE "colorschemechange"
#define EVENT_ERROR "error"
#define EVENT_MEDIA_ERROR "mediaerror"
#define EVENT_TOUCH_START "touchstart"
#define EVENT_TOUCH_MOVE "touchmove"
#define EVENT_TOUCH_END "touchend"
#define EVENT_TOUCH_CANCEL "touchcancel"
#define EVENT_MESSAGE "message"
#define EVENT_CLOSE "close"
#define EVENT_OPEN "open"
#define EVENT_INTERSECTION_CHANGE "intersectionchange"
#define EVENT_CANCEL "cancel"
#define EVENT_FINISH "finish"
#define EVENT_TRANSITION_RUN "transitionrun"
#define EVENT_TRANSITION_CANCEL "transitioncancel"
#define EVENT_TRANSITION_START "transitionstart"
#define EVENT_TRANSITION_END "transitionend"
#define EVENT_FOCUS "focus"
#define EVENT_LOAD "load"
#define EVENT_UNLOAD "unload"
#define EVENT_CHANGE "change"
#define EVENT_CAN_PLAY "canplay"
#define EVENT_CAN_PLAY_THROUGH "canplaythrough"
#define EVENT_ENDED "ended"
#define EVENT_PAUSE "pause"
#define EVENT_PLAY "play"
#define EVENT_SEEKED "seeked"
#define EVENT_SEEKING "seeking"
#define EVENT_VOLUME_CHANGE "volumechange"
#define EVENT_SCROLL "scroll"


namespace kraken::binding::jsc {

void bindEvent(std::unique_ptr<JSContext> &context);

struct NativeEvent;
class EventInstance;

class JSEvent : public HostClass {
public:
  DEFINE_OBJECT_PROPERTY(Event, 13, type, bubbles, cancelable, timestamp, defaultPrevented, target, srcElement, currentTarget, returnValue, stopPropagation, cancelBubble, stopImmediatePropagation, preventDefault)

  static std::unordered_map<JSContext *, JSEvent *> instanceMap;
  OBJECT_INSTANCE(JSEvent)
  // Create an Event Object from an nativeEvent address which allocated by dart side.
  static JSValueRef initWithNativeEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef stopPropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef stopImmediatePropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                             size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef preventDefault(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  static EventInstance* buildEventInstance(std::string &eventType, JSContext *context, void *nativeEvent, bool isCustomEvent);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSEvent() = delete;
  explicit JSEvent(JSContext *context, const char *name);
  explicit JSEvent(JSContext *context);
  ~JSEvent() override;

private:
  friend EventInstance;
  JSFunctionHolder m_initWithNativeEvent{context, this, "initWithNativeEvent", initWithNativeEvent};
  JSFunctionHolder m_stopImmediatePropagation{context, this, "stopImmediatePropagation", stopImmediatePropagation};
  JSFunctionHolder m_stopPropagation{context, this, "stopPropagation", stopPropagation};
  JSFunctionHolder m_preventDefault{context, this, "preventDefault", preventDefault};
};

class EventInstance : public HostClass::Instance {
public:
  EventInstance() = delete;

  explicit EventInstance(JSEvent *jsEvent, NativeEvent *nativeEvent);
  explicit EventInstance(JSEvent *jsEvent, std::string eventType, JSValueRef eventInit, JSValueRef *exception);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~EventInstance() override;
  NativeEvent *nativeEvent;
  bool _dispatchFlag{false};
  bool _canceledFlag{false};
  bool _initializedFlag{true};
  bool _stopPropagationFlag{false};
  bool _stopImmediatePropagationFlag{false};
  bool _inPassiveListenerFlag{false};

private:
  friend JSEvent;
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

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_EVENT_H
