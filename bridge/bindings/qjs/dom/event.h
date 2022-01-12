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

void bindEvent(std::unique_ptr<ExecutionContext>& context);

class EventInstance;

using EventCreator = EventInstance* (*)(ExecutionContext* context, void* nativeEvent);

class Event : public HostClass {
 public:
  static JSClassID kEventClassID;

  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;
  Event() = delete;
  explicit Event(ExecutionContext* context);

  static EventInstance* buildEventInstance(std::string& eventType, ExecutionContext* context, void* nativeEvent, bool isCustomEvent);
  static void defineEvent(const std::string& eventType, EventCreator creator);

  OBJECT_INSTANCE(Event);

  static JSValue stopPropagation(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue stopImmediatePropagation(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue preventDefault(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue initEvent(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

 private:
  static std::unordered_map<std::string, EventCreator> m_eventCreatorMap;

  DEFINE_PROTOTYPE_READONLY_PROPERTY(type);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(bubbles);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(cancelable);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(timestamp);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(defaultPrevented);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(target);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(srcElement);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(currentTarget);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(returnValue);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(cancelBubble);

  DEFINE_PROTOTYPE_FUNCTION(stopPropagation, 0);
  DEFINE_PROTOTYPE_FUNCTION(stopImmediatePropagation, 0);
  DEFINE_PROTOTYPE_FUNCTION(preventDefault, 1);
  DEFINE_PROTOTYPE_FUNCTION(initEvent, 3);

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
