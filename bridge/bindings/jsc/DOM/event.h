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

namespace kraken::binding::jsc {

void bindEvent(std::unique_ptr<JSContext> &context);

struct NativeEvent;
class EventInstance;

class JSEvent : public HostClass {
public:
  enum EventType {
    none,
    input,
    appear,
    disappear,
    error,
    message,
    close,
    open,
    intersectionchange,
    touchstart,
    touchend,
    touchmove,
    touchcancel,
    click,
    colorschemechange,
    load,
    finish,
    cancel,
    transitionrun,
    transitionstart,
    transitionend,
    transitioncancel,
    focus,
    unload,
    change,
    canplay,
    canplaythrough,
    ended,
    play,
    pause,
    seeked,
    seeking,
    volumechange,
    scroll
  };

  enum class EventProperty {
    kType,
    kBubbles,
    kCancelable,
    kTimestamp,
    kDefaultPrevented,
    kTarget,
    kSrcElement,
    kCurrentTarget,
    kReturnValue,
    kStopPropagation,
    kCancelBubble,
    kStopImmediatePropagation,
    kPreventDefault
  };

  static std::vector<JSStringRef> &getEventPropertyNames();
  const static std::unordered_map<std::string, EventProperty> &getEventPropertyMap();

  static JSEvent *instance(JSContext *context);
  static EventType getEventTypeOfName(std::string &name);
  static const char *getEventNameOfTypeIndex(int8_t index);

  // Create an Event Object from an nativeEvent address which allocated by dart side.
  static JSValueRef initWithNativeEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef stopPropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef stopImmediatePropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                             size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef preventDefault(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSEvent() = delete;
  explicit JSEvent(JSContext *context, const char *name);
  explicit JSEvent(JSContext *context);

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
  explicit EventInstance(JSEvent *jsEvent, JSEvent::EventType eventType);
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
  explicit NativeEvent(JSEvent::EventType eventType) : type(eventType){};
  int8_t type;
  int8_t bubbles{0};
  int8_t cancelable{0};
  int64_t timeStamp{0};
  int8_t defaultPrevented{0};
  // The pointer address of target EventTargetInstance object.
  void *target{nullptr};
  // The pointer address of current target EventTargetInstance object.
  void *currentTarget{nullptr};
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_EVENT_H
