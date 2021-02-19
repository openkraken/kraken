/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gesture_event.h"

#include <utility>

namespace kraken::binding::jsc {

void bindGestureEvent(std::unique_ptr<JSContext> &context) {
  auto GestureEvent = JSGestureEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "GestureEvent", GestureEvent->classObject);
};

std::unordered_map<JSContext *, JSGestureEvent *> JSGestureEvent::instanceMap{};

JSGestureEvent::~JSGestureEvent() {
  instanceMap.erase(context);
}

JSGestureEvent::JSGestureEvent(JSContext *context) : JSEvent(context, "GestureEvent") {}

JSObjectRef JSGestureEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to construct 'GestureEvent': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef typeArgsStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  JSValueRef gestureEventInit = nullptr;
  if (argumentCount == 2) {
    gestureEventInit = arguments[1];
  }
  std::string &&gestureEventType = JSStringToStdString(typeArgsStringRef);
  auto gestureEvent = new GestureEventInstance(JSGestureEvent::instance(context), gestureEventType, gestureEventInit, exception);
  return gestureEvent->object;
}

JSValueRef JSGestureEvent::getProperty(std::string &name, JSValueRef *exception) {
  return JSEvent::getProperty(name, exception);
}

GestureEventInstance::GestureEventInstance(JSGestureEvent *jsGestureEvent, std::string eventType, JSValueRef eventInitValue, JSValueRef *exception)
      : EventInstance(jsGestureEvent, std::move(eventType), eventInitValue, exception) {
  if (eventInitValue != nullptr) {
    JSObjectRef eventInit = JSValueToObject(ctx, eventInitValue, exception);

    if (objectHasProperty(ctx, "detail", eventInit)) {
      m_detail.setValue(getObjectPropertyValue(ctx, "detail", eventInit, exception));
    }
  }
}

GestureEventInstance::GestureEventInstance(JSGestureEvent *jsGestureEvent, NativeGestureEvent* nativeGestureEvent)
    : nativeGestureEvent(nativeGestureEvent)
    , EventInstance(jsGestureEvent, nativeGestureEvent->nativeEvent) {
  JSStringRef ref = JSStringCreateWithCharacters(nativeGestureEvent->state->string, nativeGestureEvent->state->length);
  nativeGestureEvent->state->free();
  m_detail.setValue(JSValueMakeString(context->context(), ref));
}

JSValueRef GestureEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSGestureEvent::getGestureEventPropertyMap();

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);
  auto property = propertyMap[name];

  switch (property) {
    case JSGestureEvent::GestureEventProperty::state:
      return m_detail.value();
    case JSGestureEvent::GestureEventProperty::initGestureEvent:
      return m_initGestureEvent.function();
  }

  return nullptr;
}

void GestureEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSGestureEvent::getGestureEventPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    if (property == JSGestureEvent::GestureEventProperty::state) {
      m_detail.setValue(value);
    }
  } else {
    EventInstance::setProperty(name, value, exception);
  }
}

JSValueRef GestureEventInstance::initGestureEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
      size_t argumentCount, const JSValueRef *arguments,
      JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to execute 'initGestureEvent' on 'GestureEvent': 1 argument required, but only 0 present", exception);
    return nullptr;
  }
  auto eventInstance = static_cast<GestureEventInstance *>(JSObjectGetPrivate(thisObject));

  if (eventInstance->_dispatchFlag) {
    return nullptr;
  }

  JSStringRef typeStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  eventInstance->nativeEvent->type = stringRefToNativeString(typeStringRef);

  if (argumentCount <= 2) {
    bool canBubble = JSValueToBoolean(ctx, arguments[1]);
    eventInstance->nativeEvent->bubbles = canBubble ? 1 : 0;
  }

  if (argumentCount <= 3) {
    bool cancelable = JSValueToBoolean(ctx, arguments[2]);
    eventInstance->nativeEvent->cancelable = cancelable ? 1 : 0;
  }

  if (argumentCount <= 4) {
    eventInstance->m_detail.setValue(arguments[3]);
  }

  return nullptr;
}

GestureEventInstance::~GestureEventInstance() {}

void GestureEventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventInstance::getPropertyNames(accumulator);

  for (auto &property : JSGestureEvent::getGestureEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
