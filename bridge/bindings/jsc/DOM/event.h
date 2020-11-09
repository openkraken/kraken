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
  volumechange
};

struct NativeEvent {
  NativeEvent() = delete;
  explicit NativeEvent(EventType eventType) : type(eventType){};
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

namespace {
const char *EventTypeKeys[]{
  "none",
  "input",
  "appear",
  "disappear",
  "error",
  "message",
  "close",
  "open",
  "intersectionchange",
  "touchstart",
  "touchend",
  "touchmove",
  "touchcancel",
  "click",
  "colorschemechange",
  "load",
  "finish",
  "cancel",
  "transitionrun",
  "transitionstart",
  "transitionend",
  "transitioncancel",
  "focus",
  "unload",
  "change",
  "canplay",
  "canplaythrough",
  "ended",
  "play",
  "pause",
  "seeked",
  "seeking",
  "volumechange",
};

std::unordered_map<std::string, EventType> EventTypeValues{
  {"none", EventType::none},
  {"input", EventType::input},
  {"appear", EventType::appear},
  {"disappear", EventType::disappear},
  {"error", EventType::error},
  {"message", EventType::message},
  {"close", EventType::close},
  {"open", EventType::open},
  {"intersectionchange", EventType::intersectionchange},
  {"touchstart", EventType::touchstart},
  {"touchend", EventType::touchend},
  {"touchmove", EventType::touchmove},
  {"touchcancel", EventType::touchcancel},
  {"click", EventType::click},
  {"colorschemechange", EventType::colorschemechange},
  {"load", EventType::load},
  {"finish", EventType::finish},
  {"cancel", EventType::cancel},
  {"transitionrun", EventType::transitionrun},
  {"transitionstart", EventType::transitionstart},
  {"transitionend", EventType::transitionend},
  {"transitioncancel", EventType::transitioncancel},
  {"focus", EventType::focus},
  {"unload", EventType::unload},
  {"change", EventType::change},
  {"canplay", EventType::canplay},
  {"canplaythrough", EventType::canplaythrough},
  {"ended", EventType::ended},
  {"play", EventType::play},
  {"pause", EventType::pause},
  {"seeked", EventType::seeked},
  {"seeking", EventType::seeking},
  {"volumechange", EventType::volumechange},
};
} // namespace

class JSEvent : public HostClass {
public:
  static JSEvent *instance(JSContext *context);

  JSEvent() = delete;
  explicit JSEvent(JSContext *context, const char *name);
  explicit JSEvent(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class EventInstance : public Instance {
  public:
    static std::array<JSStringRef, 8> &getEventPropertyNames();

    EventInstance() = delete;
    static JSValueRef stopPropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                      size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

    static JSValueRef stopImmediatePropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                               size_t argumentCount, const JSValueRef arguments[],
                                               JSValueRef *exception);

    static JSValueRef preventDefault(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

    explicit EventInstance(JSEvent *jsEvent, NativeEvent *nativeEvent);
    explicit EventInstance(JSEvent *jsEvent, EventType eventType);
    JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
    void setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) override;
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
    JSObjectRef _stopImmediatePropagation{nullptr};
    JSObjectRef _stopPropagation{nullptr};
    JSObjectRef _preventDefault{nullptr};
  };
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_EVENT_H
