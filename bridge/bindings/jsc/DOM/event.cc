/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event.h"
#include "eventTarget.h"
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

const char *JSEvent::getEventNameOfTypeIndex(int8_t typeIndex) {
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
  };

  return eventTypeKeys[typeIndex];
}

JSEvent::EventInstance::EventInstance(JSEvent *jsEvent, NativeEvent *nativeEvent)
  : Instance(jsEvent), nativeEvent(nativeEvent) {}

JSEvent::EventInstance::EventInstance(JSEvent *jsEvent, EventType eventType) : Instance(jsEvent) {
  nativeEvent = new NativeEvent(eventType);
  auto ms = duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
  nativeEvent->timeStamp = ms.count();
}

JSValueRef JSEvent::EventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getEventPropertyMap();

  if (!propertyMap.contains(name)) return nullptr;

  auto property = propertyMap[name];
  switch (property) {
  case EventProperty::kType: {
    JSStringRef eventStringRef = JSStringCreateWithUTF8CString(getEventNameOfTypeIndex(nativeEvent->type));
    return JSValueMakeString(_hostClass->ctx, eventStringRef);
  }
  case EventProperty::kBubbles: {
    return JSValueMakeBoolean(_hostClass->ctx, nativeEvent->bubbles);
  }
  case EventProperty::kCancelable: {
    return JSValueMakeBoolean(_hostClass->ctx, nativeEvent->cancelable);
  }
  case EventProperty::kTimestamp:
    return JSValueMakeNumber(_hostClass->ctx, nativeEvent->timeStamp);
  case EventProperty::kDefaultPrevented:
    return JSValueMakeBoolean(_hostClass->ctx, _canceledFlag);
  case EventProperty::kTarget:
  case EventProperty::kSrcElement:
    if (nativeEvent->target != nullptr) {
      auto instance = reinterpret_cast<JSEventTarget::EventTargetInstance *>(nativeEvent->target);
      return instance->object;
    }
      return JSValueMakeNull(_hostClass->ctx);
  case EventProperty::kCurrentTarget:
    if (nativeEvent->currentTarget != nullptr) {
      auto instance = reinterpret_cast<JSEventTarget::EventTargetInstance *>(nativeEvent->currentTarget);
      return instance->object;
    }
      return JSValueMakeNull(_hostClass->ctx);
  case EventProperty::kReturnValue:
    return JSValueMakeBoolean(_hostClass->ctx, !_canceledFlag);
  case EventProperty::kStopPropagation:
    if (_stopPropagation == nullptr) {
      _stopPropagation = propertyBindingFunction(_hostClass->context, this, "stopPropagation", stopPropagation);
    }
      return _stopPropagation;
  case EventProperty::kCancelBubble:
    return JSValueMakeBoolean(_hostClass->ctx, _stopPropagationFlag);
  case EventProperty::kStopImmediatePropagation:
    if (_stopImmediatePropagation == nullptr) {
      _stopImmediatePropagation =
          propertyBindingFunction(_hostClass->context, this, "stopImmediatePropagation", stopImmediatePropagation);
    }
      return _stopImmediatePropagation;
  case EventProperty::kPreventDefault:
    if (_preventDefault == nullptr) {
      _preventDefault = propertyBindingFunction(_hostClass->context, this, "preventDefault", preventDefault);
    }
      return _preventDefault;
  }

  return nullptr;
}

JSValueRef JSEvent::EventInstance::stopPropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                   size_t argumentCount, const JSValueRef *arguments,
                                                   JSValueRef *exception) {
  auto eventInstance = static_cast<JSEvent::EventInstance *>(JSObjectGetPrivate(function));
  eventInstance->_stopPropagationFlag = true;
  return nullptr;
}

JSValueRef JSEvent::EventInstance::stopImmediatePropagation(JSContextRef ctx, JSObjectRef function,
                                                            JSObjectRef thisObject, size_t argumentCount,
                                                            const JSValueRef *arguments, JSValueRef *exception) {
  auto eventInstance = static_cast<JSEvent::EventInstance *>(JSObjectGetPrivate(function));
  eventInstance->_stopPropagationFlag = true;
  eventInstance->_stopImmediatePropagationFlag = true;
  return nullptr;
}

JSValueRef JSEvent::EventInstance::preventDefault(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                  size_t argumentCount, const JSValueRef *arguments,
                                                  JSValueRef *exception) {
  auto eventInstance = static_cast<JSEvent::EventInstance *>(JSObjectGetPrivate(function));
  if (eventInstance->nativeEvent->cancelable && !eventInstance->_inPassiveListenerFlag) {
    eventInstance->_canceledFlag = true;
  }
  return nullptr;
}

void JSEvent::EventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  if (name == "cancelBubble") {
    bool v = JSValueToBoolean(_hostClass->ctx, value);
    if (v) {
      _stopPropagationFlag = true;
    }
  }
}

JSEvent::EventInstance::~EventInstance() {
  delete nativeEvent;
}
void JSEvent::EventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::vector<JSStringRef> &JSEvent::EventInstance::getEventPropertyNames() {
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

const std::unordered_map<std::string, JSEvent::EventInstance::EventProperty> &
JSEvent::EventInstance::getEventPropertyMap() {
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

} // namespace kraken::binding::jsc
