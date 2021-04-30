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
  auto gestureEvent =
    new GestureEventInstance(JSGestureEvent::instance(context), gestureEventType, gestureEventInit, exception);
  return gestureEvent->object;
}

JSValueRef JSGestureEvent::getProperty(std::string &name, JSValueRef *exception) {
  return JSEvent::getProperty(name, exception);
}

GestureEventInstance::GestureEventInstance(JSGestureEvent *jsGestureEvent, std::string eventType,
                                           JSValueRef eventInitValue, JSValueRef *exception)
  : EventInstance(jsGestureEvent, std::move(eventType), eventInitValue, exception) {
  if (eventInitValue != nullptr) {
    JSObjectRef eventInit = JSValueToObject(ctx, eventInitValue, exception);

    if (objectHasProperty(ctx, "state", eventInit)) {
      m_state.setValue(getObjectPropertyValue(ctx, "state", eventInit, exception));
    }
    if (objectHasProperty(ctx, "direction", eventInit)) {
      m_direction.setValue(getObjectPropertyValue(ctx, "direction", eventInit, exception));
    }
    if (objectHasProperty(ctx, "deltaX", eventInit)) {
      m_deltaX.setValue(getObjectPropertyValue(ctx, "deltaX", eventInit, exception));
    }
    if (objectHasProperty(ctx, "deltaY", eventInit)) {
      m_deltaY.setValue(getObjectPropertyValue(ctx, "deltaY", eventInit, exception));
    }
    if (objectHasProperty(ctx, "velocityX", eventInit)) {
      m_velocityX.setValue(getObjectPropertyValue(ctx, "velocityX", eventInit, exception));
    }
    if (objectHasProperty(ctx, "velocityY", eventInit)) {
      m_velocityY.setValue(getObjectPropertyValue(ctx, "velocityY", eventInit, exception));
    }
    if (objectHasProperty(ctx, "scale", eventInit)) {
      m_scale.setValue(getObjectPropertyValue(ctx, "scale", eventInit, exception));
    }
    if (objectHasProperty(ctx, "rotation", eventInit)) {
      m_rotation.setValue(getObjectPropertyValue(ctx, "rotation", eventInit, exception));
    }
  }
}

GestureEventInstance::GestureEventInstance(JSGestureEvent *jsGestureEvent, NativeGestureEvent *nativeGestureEvent)
  : nativeGestureEvent(nativeGestureEvent), EventInstance(jsGestureEvent, nativeGestureEvent->nativeEvent) {
  JSStringRef refState =
    JSStringCreateWithCharacters(nativeGestureEvent->state->string, nativeGestureEvent->state->length);
  nativeGestureEvent->state->free();
  JSStringRef refDirection =
    JSStringCreateWithCharacters(nativeGestureEvent->direction->string, nativeGestureEvent->direction->length);
  nativeGestureEvent->direction->free();

  m_state.setValue(JSValueMakeString(context->context(), refState));
  m_direction.setValue(JSValueMakeString(context->context(), refDirection));
  m_deltaX.setValue(JSValueMakeNumber(context->context(), nativeGestureEvent->deltaX));
  m_deltaY.setValue(JSValueMakeNumber(context->context(), nativeGestureEvent->deltaY));
  m_velocityX.setValue(JSValueMakeNumber(context->context(), nativeGestureEvent->velocityX));
  m_velocityY.setValue(JSValueMakeNumber(context->context(), nativeGestureEvent->velocityY));
  m_scale.setValue(JSValueMakeNumber(context->context(), nativeGestureEvent->scale));
  m_rotation.setValue(JSValueMakeNumber(context->context(), nativeGestureEvent->rotation));
}

JSValueRef GestureEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSGestureEvent::getGestureEventPropertyMap();
  auto prototypePropertyMap = JSGestureEvent::getGestureEventPrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSEventTarget>()->prototypeObject,
                               JSStringCreateWithUTF8CString(name.c_str()), exception);
  }

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);
  auto property = propertyMap[name];

  switch (property) {
  case JSGestureEvent::GestureEventProperty::state:
    return m_state.value();
  case JSGestureEvent::GestureEventProperty::direction:
    return m_direction.value();
  case JSGestureEvent::GestureEventProperty::deltaX:
    return m_deltaX.value();
  case JSGestureEvent::GestureEventProperty::deltaY:
    return m_deltaY.value();
  case JSGestureEvent::GestureEventProperty::velocityX:
    return m_velocityX.value();
  case JSGestureEvent::GestureEventProperty::velocityY:
    return m_velocityY.value();
  case JSGestureEvent::GestureEventProperty::scale:
    return m_scale.value();
  case JSGestureEvent::GestureEventProperty::rotation:
    return m_rotation.value();
  }

  return nullptr;
}

bool GestureEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSGestureEvent::getGestureEventPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    if (property == JSGestureEvent::GestureEventProperty::state) {
      m_state.setValue(value);
    }
    if (property == JSGestureEvent::GestureEventProperty::direction) {
      m_direction.setValue(value);
    }
    if (property == JSGestureEvent::GestureEventProperty::deltaX) {
      m_deltaX.setValue(value);
    }
    if (property == JSGestureEvent::GestureEventProperty::deltaY) {
      m_deltaY.setValue(value);
    }
    if (property == JSGestureEvent::GestureEventProperty::velocityX) {
      m_velocityX.setValue(value);
    }
    if (property == JSGestureEvent::GestureEventProperty::velocityY) {
      m_velocityY.setValue(value);
    }
    if (property == JSGestureEvent::GestureEventProperty::scale) {
      m_scale.setValue(value);
    }
    if (property == JSGestureEvent::GestureEventProperty::rotation) {
      m_rotation.setValue(value);
    }
    return true;
  } else {
    return EventInstance::setProperty(name, value, exception);
  }
}

JSValueRef JSGestureEvent::initGestureEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                            size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to execute 'initGestureEvent' on 'GestureEvent': 1 argument required, but only 0 present",
                 exception);
    return nullptr;
  }
  auto eventInstance = static_cast<GestureEventInstance *>(JSObjectGetPrivate(thisObject));

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
    eventInstance->m_state.setValue(arguments[3]);
  }

  if (argumentCount <= 5) {
    eventInstance->m_direction.setValue(arguments[4]);
  }

  if (argumentCount <= 6) {
    eventInstance->m_deltaX.setValue(arguments[5]);
  }

  if (argumentCount <= 7) {
    eventInstance->m_deltaY.setValue(arguments[6]);
  }

  if (argumentCount <= 8) {
    eventInstance->m_velocityX.setValue(arguments[7]);
  }

  if (argumentCount <= 9) {
    eventInstance->m_velocityY.setValue(arguments[8]);
  }

  if (argumentCount <= 10) {
    eventInstance->m_scale.setValue(arguments[9]);
  }

  if (argumentCount <= 11) {
    eventInstance->m_rotation.setValue(arguments[10]);
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
