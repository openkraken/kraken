/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event.h"
#include "event_target.h"
#include "bindings/jsc/DOM/custom_event.h"
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

JSValueRef JSEvent::getProperty(std::string &name, JSValueRef *exception) {
  if (name == "__initWithNativeEvent__") {
    return m_initWithNativeEvent.function();
  }
  return nullptr;
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
      auto instance = reinterpret_cast<JSEventTarget::EventTargetInstance *>(nativeEvent->target);
      return instance->object;
    }
    return JSValueMakeNull(_hostClass->ctx);
  case JSEvent::EventProperty::currentTarget:
    if (nativeEvent->currentTarget != nullptr) {
      auto instance = reinterpret_cast<JSEventTarget::EventTargetInstance *>(nativeEvent->currentTarget);
      return instance->object;
    }
    return JSValueMakeNull(_hostClass->ctx);
  case JSEvent::EventProperty::returnValue:
    return JSValueMakeBoolean(_hostClass->ctx, !_canceledFlag);
  case JSEvent::EventProperty::stopPropagation:
    return prototype<JSEvent>()->m_stopPropagation.function();
  case JSEvent::EventProperty::cancelBubble:
    return JSValueMakeBoolean(_hostClass->ctx, _stopPropagationFlag);
  case JSEvent::EventProperty::stopImmediatePropagation:
    return prototype<JSEvent>()->m_stopImmediatePropagation.function();
  case JSEvent::EventProperty::preventDefault:
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
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    if (property == JSEvent::EventProperty::cancelBubble) {
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

EventInstance *JSEvent::buildEventInstance(std::string &eventType, JSContext *context, void *nativeEvent, bool isCustomEvent) {
  EventInstance *eventInstance;
  if (isCustomEvent) {
    eventInstance = new CustomEventInstance(JSCustomEvent::instance(context), reinterpret_cast<NativeCustomEvent*>(nativeEvent));
  } else if (eventType == EVENT_INPUT) {
    eventInstance = new InputEventInstance(JSInputEvent::instance(context), reinterpret_cast<NativeInputEvent*>(nativeEvent));
  } else if (eventType == EVENT_MEDIA_ERROR) {
    eventInstance = new MediaErrorEventInstance(JSMediaErrorEvent::instance(context), reinterpret_cast<NativeMediaErrorEvent*>(nativeEvent));
  } else if (eventType == EVENT_MESSAGE) {
    eventInstance = new MessageEventInstance(JSMessageEvent::instance(context), reinterpret_cast<NativeMessageEvent*>(nativeEvent));
  } else if (eventType == EVENT_CLOSE) {
    eventInstance = new CloseEventInstance(JSCloseEvent::instance(context), reinterpret_cast<NativeCloseEvent*>(nativeEvent));
  } else if (eventType == EVENT_INTERSECTION_CHANGE) {
    eventInstance = new IntersectionChangeEventInstance(JSIntersectionChangeEvent::instance(context), reinterpret_cast<NativeIntersectionChangeEvent*>(nativeEvent));
  } else if (eventType == EVENT_TOUCH_START || eventType == EVENT_TOUCH_END || eventType == EVENT_TOUCH_MOVE || eventType == EVENT_TOUCH_CANCEL) {
    eventInstance = new TouchEventInstance(JSTouchEvent::instance(context), reinterpret_cast<NativeTouchEvent *>(nativeEvent));
  } else {
    eventInstance = new EventInstance(JSEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent));
  }

  return eventInstance;
}

} // namespace kraken::binding::jsc
