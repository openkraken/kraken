/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event.h"
#include "event_target.h"
#include "bindings/jsc/DOM/events/input_event.h"
#include "bindings/jsc/DOM/events/media_error_event.h"
#include "bindings/jsc/DOM/events/message_event.h"
#include "bindings/jsc/DOM/events/close_event.h"
#include "bindings/jsc/DOM/events/intersection_change_event.h"
#include <chrono>

namespace kraken::binding::jsc {

void bindEvent(std::unique_ptr<JSContext> &context) {
  auto event = JSEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Event", event->classObject);
};

JSEvent *JSEvent::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSEvent *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSEvent(context);
  }
  return instanceMap[context];
}

JSEvent::EventType JSEvent::getEventTypeOfName(std::string &name) {
  static std::unordered_map<std::string, EventType> eventTypeMap{
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
    {"scroll", EventType::scroll}
  };

  if (!eventTypeMap.contains(name)) return EventType::none;

  return eventTypeMap[name];
}

JSEvent::JSEvent(JSContext *context) : HostClass(context, "Event") {}
JSEvent::JSEvent(JSContext *context, const char *name) : HostClass(context, name) {}

JSObjectRef JSEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                         const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to construct 'Event': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  const JSValueRef eventTypeValueRef = arguments[0];
  JSStringRef eventTypeStringRef = JSValueToStringCopy(ctx, eventTypeValueRef, exception);
  std::string &&eventTypeName = JSStringToStdString(eventTypeStringRef);
  EventType eventType = getEventTypeOfName(eventTypeName);
  auto event = new EventInstance(this, eventType);
  return event->object;
}

const char *JSEvent::getEventNameOfTypeIndex(int64_t typeIndex) {
  static const char *eventTypeKeys[]{
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
    "scroll"
  };

  return eventTypeKeys[typeIndex];
}

JSValueRef JSEvent::initWithNativeEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 2) {
    JSC_THROW_ERROR(ctx, "Failed to execute Event.initWithNativeEvent(): invalid arguments.", exception);
    return nullptr;
  }

  auto Event = reinterpret_cast<JSEvent*>(JSObjectGetPrivate(function));
  double type = JSValueToNumber(ctx, arguments[0], exception);
  double address = JSValueToNumber(ctx, arguments[1], exception);
  auto nativeEvent = reinterpret_cast<NativeEvent*>(static_cast<int64_t>(address));
  auto event = JSEvent::buildEventInstance(static_cast<JSEvent::EventType>(type), Event->context, nativeEvent);
  return event->object;
}

JSValueRef JSEvent::getProperty(std::string &name, JSValueRef *exception) {
  if (name == "__initWithNativeEvent__") {
    return m_initWithNativeEvent.function();
  }
  return nullptr;
}

EventInstance::EventInstance(JSEvent *jsEvent, NativeEvent *nativeEvent)
  : Instance(jsEvent), nativeEvent(nativeEvent) {}

EventInstance::EventInstance(JSEvent *jsEvent, JSEvent::EventType eventType) : Instance(jsEvent) {
  nativeEvent = new NativeEvent(eventType);
  auto ms = duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
  nativeEvent->timeStamp = ms.count();
}

JSValueRef EventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSEvent::getEventPropertyMap();

  if (!propertyMap.contains(name)) return Instance::getProperty(name, exception);

  auto property = propertyMap[name];
  switch (property) {
  case JSEvent::EventProperty::kType: {
    JSStringRef eventStringRef = JSStringCreateWithUTF8CString(JSEvent::getEventNameOfTypeIndex(nativeEvent->type));
    return JSValueMakeString(_hostClass->ctx, eventStringRef);
  }
  case JSEvent::EventProperty::kBubbles: {
    return JSValueMakeBoolean(_hostClass->ctx, nativeEvent->bubbles);
  }
  case JSEvent::EventProperty::kCancelable: {
    return JSValueMakeBoolean(_hostClass->ctx, nativeEvent->cancelable);
  }
  case JSEvent::EventProperty::kTimestamp:
    return JSValueMakeNumber(_hostClass->ctx, nativeEvent->timeStamp);
  case JSEvent::EventProperty::kDefaultPrevented:
    return JSValueMakeBoolean(_hostClass->ctx, _canceledFlag);
  case JSEvent::EventProperty::kTarget:
  case JSEvent::EventProperty::kSrcElement:
    if (nativeEvent->target != nullptr) {
      auto instance = reinterpret_cast<JSEventTarget::EventTargetInstance *>(nativeEvent->target);
      return instance->object;
    }
    return JSValueMakeNull(_hostClass->ctx);
  case JSEvent::EventProperty::kCurrentTarget:
    if (nativeEvent->currentTarget != nullptr) {
      auto instance = reinterpret_cast<JSEventTarget::EventTargetInstance *>(nativeEvent->currentTarget);
      return instance->object;
    }
    return JSValueMakeNull(_hostClass->ctx);
  case JSEvent::EventProperty::kReturnValue:
    return JSValueMakeBoolean(_hostClass->ctx, !_canceledFlag);
  case JSEvent::EventProperty::kStopPropagation:
    return prototype<JSEvent>()->m_stopPropagation.function();
  case JSEvent::EventProperty::kCancelBubble:
    return JSValueMakeBoolean(_hostClass->ctx, _stopPropagationFlag);
  case JSEvent::EventProperty::kStopImmediatePropagation:
    return prototype<JSEvent>()->m_stopImmediatePropagation.function();
  case JSEvent::EventProperty::kPreventDefault:
    return prototype<JSEvent>()->m_preventDefault.function();
  }

  return nullptr;
}

JSValueRef JSEvent::stopPropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                   size_t argumentCount, const JSValueRef *arguments,
                                                   JSValueRef *exception) {
  auto eventInstance = static_cast<EventInstance *>(JSObjectGetPrivate(thisObject));
  eventInstance->_stopPropagationFlag = true;
  return nullptr;
}

JSValueRef JSEvent::stopImmediatePropagation(JSContextRef ctx, JSObjectRef function,
                                                            JSObjectRef thisObject, size_t argumentCount,
                                                            const JSValueRef *arguments, JSValueRef *exception) {
  auto eventInstance = static_cast<EventInstance *>(JSObjectGetPrivate(thisObject));
  eventInstance->_stopPropagationFlag = true;
  eventInstance->_stopImmediatePropagationFlag = true;
  return nullptr;
}

JSValueRef JSEvent::preventDefault(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                  size_t argumentCount, const JSValueRef *arguments,
                                                  JSValueRef *exception) {
  auto eventInstance = static_cast<EventInstance *>(JSObjectGetPrivate(thisObject));
  if (eventInstance->nativeEvent->cancelable && !eventInstance->_inPassiveListenerFlag) {
    eventInstance->_canceledFlag = true;
  }
  return nullptr;
}

void EventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSEvent::getEventPropertyMap();
  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    if (property == JSEvent::EventProperty::kCancelBubble) {
      bool v = JSValueToBoolean(_hostClass->ctx, value);
      if (v) {
        _stopPropagationFlag = true;
      }
    }
  } else {
    Instance::setProperty(name, value, exception);
  }
}

EventInstance::~EventInstance() {
  delete nativeEvent;
}
void EventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : JSEvent::getEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::vector<JSStringRef> &JSEvent::getEventPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("type"),
    JSStringCreateWithUTF8CString("bubbles"),
    JSStringCreateWithUTF8CString("cancelable"),
    JSStringCreateWithUTF8CString("timeStamp"),
    JSStringCreateWithUTF8CString("defaultPrevented"),
    JSStringCreateWithUTF8CString("target"),
    JSStringCreateWithUTF8CString("currentTarget"),
    JSStringCreateWithUTF8CString("srcElement"),
    JSStringCreateWithUTF8CString("returnValue"),
    JSStringCreateWithUTF8CString("stopPropagation"),
    JSStringCreateWithUTF8CString("cancelBubble"),
    JSStringCreateWithUTF8CString("stopImmediatePropagation"),
    JSStringCreateWithUTF8CString("preventDefault"),
  };
  return propertyNames;
}

const std::unordered_map<std::string, JSEvent::EventProperty> &JSEvent::getEventPropertyMap() {
  static std::unordered_map<std::string, EventProperty> propertyMap{
    {"type", EventProperty::kType},
    {"bubbles", EventProperty::kBubbles},
    {"cancelable", EventProperty::kCancelable},
    {"timeStamp", EventProperty::kTimestamp},
    {"defaultPrevented", EventProperty::kDefaultPrevented},
    {"target", EventProperty::kTarget},
    {"srcElement", EventProperty::kSrcElement},
    {"currentTarget", EventProperty::kCurrentTarget},
    {"returnValue", EventProperty::kReturnValue},
    {"stopPropagation", EventProperty::kStopPropagation},
    {"cancelBubble", EventProperty::kCancelable},
    {"stopImmediatePropagation", EventProperty::kStopImmediatePropagation},
    {"preventDefault", EventProperty::kPreventDefault}};
  return propertyMap;
}

EventInstance *JSEvent::buildEventInstance(JSEvent::EventType eventType, JSContext *context, void *nativeEvent) {
  EventInstance *eventInstance;
  switch(eventType) {
    case JSEvent::EventType::input: {
      eventInstance = new InputEventInstance(JSInputEvent::instance(context), reinterpret_cast<NativeInputEvent*>(nativeEvent));
      break;
    }
    case JSEvent::EventType::error: {
      eventInstance = new MediaErrorEventInstance(JSMediaErrorEvent::instance(context), reinterpret_cast<NativeMediaErrorEvent*>(nativeEvent));
      break;
    }
    case JSEvent::EventType::message: {
      eventInstance = new MessageEventInstance(JSMessageEvent::instance(context), reinterpret_cast<NativeMessageEvent*>(nativeEvent));
      break;
    }
    case JSEvent::EventType::close: {
      eventInstance = new CloseEventInstance(JSCloseEvent::instance(context), reinterpret_cast<NativeCloseEvent*>(nativeEvent));
      break;
    }
    case JSEvent::EventType::intersectionchange: {
      eventInstance = new IntersectionChangeEventInstance(JSIntersectionChangeEvent::instance(context), reinterpret_cast<NativeIntersectionChangeEvent*>(nativeEvent));
      break;
    }
    default:
      eventInstance = new EventInstance(JSEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent));
  }

  return eventInstance;
}

} // namespace kraken::binding::jsc
