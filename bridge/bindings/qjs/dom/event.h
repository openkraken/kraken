/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_H
#define KRAKENBRIDGE_EVENT_H

#include "bindings/qjs/host_class.h"

namespace kraken::binding::qjs {

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
#define EVENT_POPSTATE "popstate"
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
#define EVENT_SWIPE "swipe"
#define EVENT_PAN "pan"
#define EVENT_LONG_PRESS "longpress"
#define EVENT_SCALE "scale"

void bindEvent(std::unique_ptr<JSContext>& context);

class EventInstance;

using EventCreator = EventInstance* (*)(JSContext* context, void* nativeEvent);

class Event : public HostClass {
 public:
  static JSClassID kEventClassID;

  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;
  Event() = delete;
  explicit Event(JSContext* context);

  static EventInstance* buildEventInstance(std::string& eventType, JSContext* context, void* nativeEvent, bool isCustomEvent);
  static void defineEvent(const std::string& eventType, EventCreator creator);

  OBJECT_INSTANCE(Event);

  static JSValue stopPropagation(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue stopImmediatePropagation(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue preventDefault(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue initEvent(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

 private:
  static std::unordered_map<std::string, EventCreator> m_eventCreatorMap;
  DEFINE_HOST_CLASS_PROTOTYPE_GETTER_PROPERTY(9, type, bubbles, cancelable, timestamp, defaultPrevented, target, srcElement, currentTarget, returnValue)
  DEFINE_HOST_CLASS_PROTOTYPE_PROPERTY(1, cancelBubble)

  ObjectFunction m_stopPropagation{m_context, m_prototypeObject, "stopPropagation", stopPropagation, 0};
  ObjectFunction m_stopImmediatePropagation{m_context, m_prototypeObject, "immediatePropagation", stopImmediatePropagation, 0};
  ObjectFunction m_preventDefault{m_context, m_prototypeObject, "preventDefault", preventDefault, 1};
  ObjectFunction m_initEvent{m_context, m_prototypeObject, "initEvent", initEvent, 3};

  friend EventInstance;
};

struct NativeEvent {
  NativeString* type{nullptr};
  int64_t bubbles{0};
  int64_t cancelable{0};
  int64_t timeStamp{0};
  int64_t defaultPrevented{0};
  // The pointer address of target EventTargetInstance object.
  void* target{nullptr};
  // The pointer address of current target EventTargetInstance object.
  void* currentTarget{nullptr};
};

struct RawEvent {
  uint64_t* bytes;
  int64_t length;
};

class EventInstance : public Instance {
 public:
  EventInstance() = delete;
  ~EventInstance() override { delete nativeEvent; }

  static EventInstance* fromNativeEvent(Event* event, NativeEvent* nativeEvent);
  NativeEvent* nativeEvent{nullptr};

  inline const bool propagationStopped() { return m_propagationStopped; }
  inline const bool cancelled() { return m_cancelled; }
  inline void cancelled(bool v) { m_cancelled = v; }
  inline const bool propagationImmediatelyStopped() { return m_propagationImmediatelyStopped; }

 protected:
  explicit EventInstance(Event* jsEvent, JSAtom eventType, JSValue eventInit);
  explicit EventInstance(Event* jsEvent, NativeEvent* nativeEvent);
  bool m_cancelled{false};
  bool m_propagationStopped{false};
  bool m_propagationImmediatelyStopped{false};

 private:
  static void finalizer(JSRuntime* rt, JSValue val);
  friend Event;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_EVENT_H
