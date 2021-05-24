/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "touch_event.h"

namespace kraken::binding::jsc {

void bindTouchEvent(std::unique_ptr<JSContext> &context) {
  auto event = JSTouchEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "TouchEvent", event->classObject);
};

std::unordered_map<JSContext *, JSTouchEvent *> JSTouchEvent::instanceMap {};

JSTouchEvent::~JSTouchEvent() {
  instanceMap.erase(context);
}

JSTouchEvent::JSTouchEvent(JSContext *context) : JSEvent(context, "TouchEvent") {}

JSObjectRef JSTouchEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                              const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    throwJSError(ctx, "Failed to construct 'JSTouchEvent': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef dataStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  auto event = new TouchEventInstance(this, dataStringRef);
  return event->object;
}

JSValueRef JSTouchEvent::getProperty(std::string &name, JSValueRef *exception) {
  return nullptr;
}

TouchEventInstance::TouchEventInstance(JSTouchEvent *jsTouchEvent, NativeTouchEvent *nativeTouchEvent)
  : EventInstance(jsTouchEvent, nativeTouchEvent->nativeEvent), nativeTouchEvent(nativeTouchEvent) {
  m_touches = new JSTouchList(jsTouchEvent->context, nativeTouchEvent->touches, nativeTouchEvent->touchLength);
  m_targetTouches = new JSTouchList(jsTouchEvent->context, nativeTouchEvent->targetTouches, nativeTouchEvent->targetTouchesLength);
  m_changedTouches = new JSTouchList(jsTouchEvent->context, nativeTouchEvent->changedTouches, nativeTouchEvent->changedTouchesLength);
}

TouchEventInstance::TouchEventInstance(JSTouchEvent *jsTouchEvent, JSStringRef data)
  : EventInstance(jsTouchEvent, "touch", nullptr, nullptr) {
  nativeTouchEvent = new NativeTouchEvent(nativeEvent);
}

JSValueRef TouchEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = JSTouchEvent::getTouchEventPropertyMap();

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);

  auto &property = propertyMap[name];

  switch (property) {
  case JSTouchEvent::TouchEventProperty::touches:
    return m_touches->jsObject;
  case JSTouchEvent::TouchEventProperty::targetTouches:
    return m_targetTouches->jsObject;
  case JSTouchEvent::TouchEventProperty::changedTouches:
    return m_changedTouches->jsObject;
  case JSTouchEvent::TouchEventProperty::altKey:
    return JSValueMakeBoolean(ctx, nativeTouchEvent->altKey == 1);
  case JSTouchEvent::TouchEventProperty::metaKey:
    return JSValueMakeBoolean(ctx, nativeTouchEvent->metaKey == 1);
  case JSTouchEvent::TouchEventProperty::ctrlKey:
    return JSValueMakeBoolean(ctx, nativeTouchEvent->ctrlKey == 1);
  case JSTouchEvent::TouchEventProperty::shiftKey:
    return JSValueMakeBoolean(ctx, nativeTouchEvent->shiftKey == 1);
  }

  return nullptr;
}

bool TouchEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto &propertyMap = JSTouchEvent::getTouchEventPropertyMap();
  if (propertyMap.count(name) > 0) {
    return true;
  } else {
    return EventInstance::setProperty(name, value, exception);
  }
}

TouchEventInstance::~TouchEventInstance() {
  delete nativeTouchEvent;
}

void TouchEventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventInstance::getPropertyNames(accumulator);

  for (auto &property : JSTouchEvent::getTouchEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSTouchList::JSTouchList(JSContext *context, NativeTouch **touches, int64_t length) : HostObject(context, "TouchList") {
  m_touchList.reserve(length);
  for (size_t i = 0; i < length; i++) {
    auto touch = new JSTouch(context, touches[i]);
    m_touchList.emplace_back(touch);
  }
}

JSValueRef kraken::binding::jsc::JSTouchList::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = getTouchListPropertyMap();

  if (isNumberIndex(name)) {
    size_t index = std::stoi(name);
    return m_touchList[index]->jsObject;
  } else if (propertyMap.count(name) > 0) {
    auto &property = propertyMap[name];

    if (property == TouchListProperty::length) {
      return JSValueMakeNumber(ctx, m_touchList.size());
    }
  } else {
    return HostObject::getProperty(name, exception);
  }

  return nullptr;
}

void JSTouchList::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  HostObject::getPropertyNames(accumulator);

  for (auto &property : getTouchListPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (size_t i = 0; i < m_touchList.size(); i ++) {
    JSPropertyNameAccumulatorAddName(accumulator, JSStringCreateWithUTF8CString(std::to_string(i).c_str()));
  }
}

JSTouch::JSTouch(JSContext *context, NativeTouch *touch) : HostObject(context, "Touch"), m_nativeTouch(touch) {}

JSValueRef JSTouch::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = getTouchPropertyMap();

  if (propertyMap.count(name) > 0) {
    auto &property = propertyMap[name];

    switch(property) {
    case TouchProperty::identifier:
      return JSValueMakeNumber(ctx, m_nativeTouch->identifier);
    case TouchProperty::target:
      return m_nativeTouch->target->instance->object;
    case TouchProperty::clientX:
      return JSValueMakeNumber(ctx, m_nativeTouch->clientX);
    case TouchProperty::clientY:
      return JSValueMakeNumber(ctx, m_nativeTouch->clientY);
    case TouchProperty::screenX:
      return JSValueMakeNumber(ctx, m_nativeTouch->screenX);
    case TouchProperty::screenY:
      return JSValueMakeNumber(ctx, m_nativeTouch->screenY);
    case TouchProperty::pageX:
      return JSValueMakeNumber(ctx, m_nativeTouch->pageX);
    case TouchProperty::pageY:
      return JSValueMakeNumber(ctx, m_nativeTouch->pageY);
    case TouchProperty::radiusX:
      return JSValueMakeNumber(ctx, m_nativeTouch->radiusX);
    case TouchProperty::radiusY:
      return JSValueMakeNumber(ctx, m_nativeTouch->radiusY);
    case TouchProperty::rotationAngle:
      return JSValueMakeNumber(ctx, m_nativeTouch->rotationAngle);
    case TouchProperty::force:
      return JSValueMakeNumber(ctx, m_nativeTouch->force);
    case TouchProperty::altitudeAngle:
      return JSValueMakeNumber(ctx, m_nativeTouch->altitudeAngle);
    case TouchProperty::azimuthAngle:
      return JSValueMakeNumber(ctx, m_nativeTouch->azimuthAngle);
    case TouchProperty::touchType:
      return JSValueMakeNumber(ctx, m_nativeTouch->touchType);
    }
  }

  return HostObject::getProperty(name, exception);
}

JSTouch::~JSTouch() {
  delete m_nativeTouch;
}

void JSTouch::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  HostObject::getPropertyNames(accumulator);

  for (auto &property : getTouchPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
