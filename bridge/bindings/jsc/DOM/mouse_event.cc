/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "mouse_event.h"

#include <utility>

namespace kraken::binding::jsc {

void bindMouseEvent(std::unique_ptr<JSContext> &context) {
  auto MouseEvent = JSMouseEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "MouseEvent", MouseEvent->classObject);
};

std::unordered_map<JSContext *, JSMouseEvent *> JSMouseEvent::instanceMap{};

JSMouseEvent::~JSMouseEvent() {
  instanceMap.erase(context);
}

JSMouseEvent::JSMouseEvent(JSContext *context) : JSEvent(context, "MouseEvent") {}

JSObjectRef JSMouseEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to construct 'MouseEvent': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef typeArgsStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  JSValueRef mouseEventInit = nullptr;
  if (argumentCount == 2) {
    mouseEventInit = arguments[1];
  }
  std::string &&mouseEventType = JSStringToStdString(typeArgsStringRef);
  auto mouseEvent =
    new MouseEventInstance(JSMouseEvent::instance(context), mouseEventType, mouseEventInit, exception);
  return mouseEvent->object;
}

JSValueRef JSMouseEvent::getProperty(std::string &name, JSValueRef *exception) {
  return JSEvent::getProperty(name, exception);
}

MouseEventInstance::MouseEventInstance(JSMouseEvent *jsMouseEvent, std::string eventType,
                                           JSValueRef eventInitValue, JSValueRef *exception)
  : EventInstance(jsMouseEvent, std::move(eventType), eventInitValue, exception) {
  if (eventInitValue != nullptr) {
    JSObjectRef eventInit = JSValueToObject(ctx, eventInitValue, exception);

    if (objectHasProperty(ctx, "clientX", eventInit)) {
      m_clientX.setValue(getObjectPropertyValue(ctx, "clientX", eventInit, exception));
    }
    if (objectHasProperty(ctx, "clientY", eventInit)) {
      m_clientY.setValue(getObjectPropertyValue(ctx, "clientY", eventInit, exception));
    }
    if (objectHasProperty(ctx, "offsetX", eventInit)) {
      m_offsetX.setValue(getObjectPropertyValue(ctx, "offsetX", eventInit, exception));
    }
    if (objectHasProperty(ctx, "offsetX", eventInit)) {
      m_offsetY.setValue(getObjectPropertyValue(ctx, "offsetX", eventInit, exception));
    }
  }
}

MouseEventInstance::MouseEventInstance(JSMouseEvent *jsMouseEvent, NativeMouseEvent *nativeMouseEvent)
  : nativeMouseEvent(nativeMouseEvent), EventInstance(jsMouseEvent, nativeMouseEvent->nativeEvent) {
  m_clientX.setValue(JSValueMakeNumber(context->context(), nativeMouseEvent->clientX));
  m_clientY.setValue(JSValueMakeNumber(context->context(), nativeMouseEvent->clientY));
  m_offsetX.setValue(JSValueMakeNumber(context->context(), nativeMouseEvent->offsetX));
  m_offsetY.setValue(JSValueMakeNumber(context->context(), nativeMouseEvent->offsetY));
}

JSValueRef MouseEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSMouseEvent::getMouseEventPropertyMap();
  auto prototypePropertyMap = JSMouseEvent::getMouseEventPrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSEventTarget>()->prototypeObject,
                               JSStringCreateWithUTF8CString(name.c_str()), exception);
  }

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);
  auto property = propertyMap[name];

  switch (property) {
  case JSMouseEvent::MouseEventProperty::clientX:
    return m_clientX.value();
  case JSMouseEvent::MouseEventProperty::clientY:
    return m_clientY.value();
  case JSMouseEvent::MouseEventProperty::offsetX:
    return m_offsetX.value();
  case JSMouseEvent::MouseEventProperty::offsetY:
    return m_offsetY.value();
  }

  return nullptr;
}

bool MouseEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSMouseEvent::getMouseEventPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
      case JSMouseEvent::MouseEventProperty::clientX:
        m_clientX.setValue(value);
      case JSMouseEvent::MouseEventProperty::clientY:
        m_clientY.setValue(value);
      case JSMouseEvent::MouseEventProperty::offsetX:
        m_offsetX.setValue(value);
      case JSMouseEvent::MouseEventProperty::offsetY:
        m_offsetY.setValue(value);
    }

    return true;
  } else {
    return EventInstance::setProperty(name, value, exception);
  }
}

JSValueRef JSMouseEvent::initMouseEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                            size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to execute 'initMouseEvent' on 'MouseEvent': 1 argument required, but only 0 present",
                 exception);
    return nullptr;
  }
  auto eventInstance = static_cast<MouseEventInstance *>(JSObjectGetPrivate(thisObject));

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
    eventInstance->m_clientX.setValue(arguments[3]);
  }

  if (argumentCount <= 5) {
    eventInstance->m_clientY.setValue(arguments[4]);
  }

  if (argumentCount <= 6) {
    eventInstance->m_offsetX.setValue(arguments[5]);
  }

  if (argumentCount <= 7) {
    eventInstance->m_offsetY.setValue(arguments[6]);
  }

  return nullptr;
}

MouseEventInstance::~MouseEventInstance() {}

void MouseEventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventInstance::getPropertyNames(accumulator);

  for (auto &property : JSMouseEvent::getMouseEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
