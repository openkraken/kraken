/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event.h"
#include "event_target.h"
#include "bindings/jsc/DOM/custom_event.h"
#include "bindings/jsc/DOM/gesture_event.h"
#include "bindings/jsc/DOM/events/input_event.h"
#include "bindings/jsc/DOM/events/media_error_event.h"
#include "bindings/jsc/DOM/events/message_event.h"
#include "bindings/jsc/DOM/events/close_event.h"
#include "bindings/jsc/DOM/events/intersection_change_event.h"
#include "bindings/jsc/DOM/events/touch_event.h"
#include <chrono>

namespace kraken::binding::jsc {

void bindEvent(std::unique_ptr<JSContext> &context) {
  auto event = JSEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Event", event->classObject);
};

std::unordered_map<JSContext *, JSEvent *> JSEvent::instanceMap{};
std::unordered_map<std::string, EventCreator> JSEvent::eventCreatorMap{};

JSEvent::~JSEvent() {
  instanceMap.erase(context);
}

JSEvent::JSEvent(JSContext *context) : HostClass(context, "Event") {}
JSEvent::JSEvent(JSContext *context, const char *name) : HostClass(context, name) {}

JSObjectRef JSEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                         const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to construct 'Event': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  const JSValueRef eventTypeValueRef = arguments[0];
  JSStringRef eventTypeStringRef = JSValueToStringCopy(ctx, eventTypeValueRef, exception);
  std::string &&eventType = JSStringToStdString(eventTypeStringRef);
  auto nativeEvent = new NativeEvent(stringToNativeString(eventType));
  auto event = JSEvent::buildEventInstance(eventType, context, nativeEvent, false);

  return event->object;
}

JSValueRef JSEvent::initWithNativeEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 2) {
    throwJSError(ctx, "Failed to execute Event.initWithNativeEvent(): invalid arguments.", exception);
    return nullptr;
  }

  auto Event = reinterpret_cast<JSEvent*>(JSObjectGetPrivate(function));
  JSStringRef eventTypeStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  double address = JSValueToNumber(ctx, arguments[1], exception);
  auto nativeEvent = reinterpret_cast<NativeEvent*>(static_cast<int64_t>(address));
  std::string eventType = JSStringToStdString(eventTypeStringRef);
  auto event = JSEvent::buildEventInstance(eventType, Event->context, nativeEvent, false);
  return event->object;
}

void JSEvent::defineEvent(std::string eventType, EventCreator creator) {
  if (eventCreatorMap.count(eventType) > 0) {
    return;
  }

  eventCreatorMap[eventType] = creator;
}
JSValueRef JSEvent::getProperty(std::string &name, JSValueRef *exception) {
  if (name == "__initWithNativeEvent__") return nullptr;
  return HostClass::getProperty(name, exception);
}

EventInstance::EventInstance(JSEvent *jsEvent, NativeEvent *nativeEvent)
  : Instance(jsEvent), nativeEvent(nativeEvent) {}

EventInstance::EventInstance(JSEvent *jsEvent, std::string eventType, JSValueRef eventInitValueRef, JSValueRef *exception) : Instance(jsEvent) {
  nativeEvent = new NativeEvent(stringToNativeString(eventType));
  auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
  nativeEvent->timeStamp = ms.count();

  if (eventInitValueRef != nullptr) {;
    JSObjectRef eventInit = JSValueToObject(ctx, eventInitValueRef, exception);

    if (objectHasProperty(ctx, "bubbles", eventInit)) {
      nativeEvent->bubbles = JSValueToBoolean(ctx, getObjectPropertyValue(ctx, "bubbles", eventInit, exception)) ? 1 : 0;
    }
    if (objectHasProperty(ctx, "cancelable", eventInit)) {
      nativeEvent->cancelable = JSValueToBoolean(ctx, getObjectPropertyValue(ctx, "cancelable", eventInit, exception)) ? 1 : 0;
    }
  }
}

JSValueRef EventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSEvent::getEventPropertyMap();
  auto prototypeProperty = JSEvent::getEventPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  if (prototypeProperty.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSEvent>()->prototypeObject, nameStringHolder.getString(), exception);
  }

  if (propertyMap.count(name) == 0) return Instance::getProperty(name, exception);

  auto property = propertyMap[name];
  switch (property) {
  case JSEvent::EventProperty::type: {
    JSStringRef eventStringRef = JSStringCreateWithCharacters(nativeEvent->type->string, nativeEvent->type->length);
    return JSValueMakeString(_hostClass->ctx, eventStringRef);
  }
  case JSEvent::EventProperty::bubbles: {
    return JSValueMakeBoolean(_hostClass->ctx, nativeEvent->bubbles);
  }
  case JSEvent::EventProperty::cancelable: {
    return JSValueMakeBoolean(_hostClass->ctx, nativeEvent->cancelable);
  }
  case JSEvent::EventProperty::timestamp:
    return JSValueMakeNumber(_hostClass->ctx, nativeEvent->timeStamp);
  case JSEvent::EventProperty::defaultPrevented:
    return JSValueMakeBoolean(_hostClass->ctx, _canceledFlag);
  case JSEvent::EventProperty::target:
  case JSEvent::EventProperty::srcElement:
    if (nativeEvent->target != nullptr) {
      auto instance = reinterpret_cast<EventTargetInstance *>(nativeEvent->target);
      return instance->object;
    }
    return JSValueMakeNull(_hostClass->ctx);
  case JSEvent::EventProperty::currentTarget:
    if (nativeEvent->currentTarget != nullptr) {
      auto instance = reinterpret_cast<EventTargetInstance *>(nativeEvent->currentTarget);
      return instance->object;
    }
    return JSValueMakeNull(_hostClass->ctx);
  case JSEvent::EventProperty::returnValue:
    return JSValueMakeBoolean(_hostClass->ctx, !_canceledFlag);
  case JSEvent::EventProperty::cancelBubble:
    return JSValueMakeBoolean(_hostClass->ctx, _stopPropagationFlag);
  }
  return nullptr;
}

JSValueRef JSEvent::initEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef *arguments,
                                    JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to initEvent required, but only 0 present.", exception);
    return nullptr;
  }

  const JSValueRef typeValueRef = arguments[0];
  const JSValueRef bubblesValueRef = arguments[1];
  const JSValueRef cancelableValueRef = arguments[2];
  if (!JSValueIsString(ctx, typeValueRef)) {
    throwJSError(ctx, "Failed to createElement: type should be a string.", exception);
    return nullptr;
  }

  JSStringRef typeStringRef = JSValueToStringCopy(ctx, typeValueRef, exception);
  std::string type = JSStringToStdString(typeStringRef);

  auto eventInstance = static_cast<EventInstance *>(JSObjectGetPrivate(thisObject));
  eventInstance->nativeEvent->type = stringToNativeString(type);
  eventInstance->nativeEvent->bubbles = JSValueToBoolean(ctx, bubblesValueRef) ? 1 : 0;
  eventInstance->nativeEvent->cancelable = JSValueToBoolean(ctx, cancelableValueRef) ? 1 : 0;

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

bool EventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSEvent::getEventPropertyMap();
  auto prototypePropertyMap = JSEvent::getEventPrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) return false;

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    if (property == JSEvent::EventProperty::cancelBubble) {
      bool v = JSValueToBoolean(_hostClass->ctx, value);
      if (v) {
        _stopPropagationFlag = true;
      }
    }
    return true;
  } else {
    return Instance::setProperty(name, value, exception);
  }
}

EventInstance::~EventInstance() {
  nativeEvent->type->free();
  delete nativeEvent;
}
void EventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : JSEvent::getEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (auto &property : JSEvent::getEventPrototypePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

EventInstance *JSEvent::buildEventInstance(std::string &eventType, JSContext *context, void *nativeEvent, bool isCustomEvent) {
  EventInstance *eventInstance;
  if (isCustomEvent) {
    eventInstance = new CustomEventInstance(JSCustomEvent::instance(context), reinterpret_cast<NativeCustomEvent*>(nativeEvent));
  } else if (eventCreatorMap.count(eventType) > 0) {
    eventInstance = eventCreatorMap[eventType](context, nativeEvent);
  } else {
    eventInstance = new EventInstance(JSEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent));
  }

  return eventInstance;
}

} // namespace kraken::binding::jsc
