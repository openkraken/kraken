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

std::unordered_map<JSContext *, JSTouchEvent *> &JSTouchEvent::getInstanceMap() {
  static std::unordered_map<JSContext *, JSTouchEvent *> instanceMap;
  return instanceMap;
}

JSTouchEvent *JSTouchEvent::instance(JSContext *context) {
  auto instanceMap = getInstanceMap();
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSTouchEvent(context);
  }
  return instanceMap[context];
}

JSTouchEvent::~JSTouchEvent() {
  auto instanceMap = getInstanceMap();
  instanceMap.erase(context);
}

JSTouchEvent::JSTouchEvent(JSContext *context) : JSEvent(context, "TouchEvent") {}

JSObjectRef JSTouchEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                              const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to construct 'JSTouchEvent': 1 argument required, but only 0 present.", exception);
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
  auto propertyMap = JSTouchEvent::getTouchEventPropertyMap();

  if (!propertyMap.contains(name)) return EventInstance::getProperty(name, exception);

  auto property = propertyMap[name];

  switch (property) {
  case JSTouchEvent::TouchEventProperty::kTouches:
    return m_touches->jsObject;
  case JSTouchEvent::TouchEventProperty::kTargetTouches:
    return m_targetTouches->jsObject;
  case JSTouchEvent::TouchEventProperty::kChangedTouches:
    return m_changedTouches->jsObject;
  case JSTouchEvent::TouchEventProperty::kAltKey:
    return JSValueMakeBoolean(ctx, nativeTouchEvent->altKey == 1);
  case JSTouchEvent::TouchEventProperty::kMetaKey:
    return JSValueMakeBoolean(ctx, nativeTouchEvent->metaKey == 1);
  case JSTouchEvent::TouchEventProperty::kCtrlKey:
    return JSValueMakeBoolean(ctx, nativeTouchEvent->ctrlKey == 1);
  case JSTouchEvent::TouchEventProperty::kShiftKey:
    return JSValueMakeBoolean(ctx, nativeTouchEvent->shiftKey == 1);
  }

  return nullptr;
}

void TouchEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSTouchEvent::getTouchEventPropertyMap();
  if (propertyMap.contains(name)) {
   return;
  } else {
    EventInstance::setProperty(name, value, exception);
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

std::vector<JSStringRef> &JSTouchEvent::getTouchEventPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("altKey"),   JSStringCreateWithUTF8CString("changedTouches"),
    JSStringCreateWithUTF8CString("ctrlKey"),  JSStringCreateWithUTF8CString("metaKey"),
    JSStringCreateWithUTF8CString("shiftKey"), JSStringCreateWithUTF8CString("targetTouches"),
    JSStringCreateWithUTF8CString("touches")};
  return propertyNames;
}

const std::unordered_map<std::string, JSTouchEvent::TouchEventProperty> &JSTouchEvent::getTouchEventPropertyMap() {
  static std::unordered_map<std::string, TouchEventProperty> propertyMap{
    {"altKey", TouchEventProperty::kAltKey},     {"changedTouches", TouchEventProperty::kChangedTouches},
    {"ctrlKey", TouchEventProperty::kCtrlKey},   {"metaKey", TouchEventProperty::kMetaKey},
    {"shiftKey", TouchEventProperty::kShiftKey}, {"targetTouches", TouchEventProperty::kTargetTouches},
    {"touches", TouchEventProperty::kTouches}};
  return propertyMap;
}

JSTouchList::JSTouchList(JSContext *context, NativeTouch **touches, int64_t length) : HostObject(context, "TouchList") {
  m_touchList.reserve(length);
  for (size_t i = 0; i < length; i++) {
    auto touch = new JSTouch(context, touches[i]);
    m_touchList.emplace_back(touch);
  }
}

std::vector<JSStringRef> &JSTouch::getTouchPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("identifier"),    JSStringCreateWithUTF8CString("target"),
    JSStringCreateWithUTF8CString("clientX"),       JSStringCreateWithUTF8CString("clientY"),
    JSStringCreateWithUTF8CString("screenX"),       JSStringCreateWithUTF8CString("screenY"),
    JSStringCreateWithUTF8CString("pageX"),         JSStringCreateWithUTF8CString("pageY"),
    JSStringCreateWithUTF8CString("radiusX"),       JSStringCreateWithUTF8CString("radiusY"),
    JSStringCreateWithUTF8CString("rotationAngle"), JSStringCreateWithUTF8CString("force"),
    JSStringCreateWithUTF8CString("altitudeAngle"), JSStringCreateWithUTF8CString("azimuthAngle"),
    JSStringCreateWithUTF8CString("touchType"),
  };
  return propertyNames;
}

const std::unordered_map<std::string, JSTouch::TouchProperty> &JSTouch::getTouchPropertyMap() {
  static std::unordered_map<std::string, TouchProperty> propertyMap{
    {"identifier", TouchProperty::kIdentifier},
    {"target", TouchProperty::kTarget},
    {"clientX", TouchProperty::kClientX},
    {"clientY", TouchProperty::kClientY},
    {"screenX", TouchProperty::kScreenX},
    {"screenY", TouchProperty::kScreenY},
    {"pageX", TouchProperty::kPageX},
    {"pageY", TouchProperty::kPageY},
    {"radiusX", TouchProperty::kRadiusX},
    {"radiusY", TouchProperty::kRadiusY},
    {"rotationAngle", TouchProperty::kRotationAngle},
    {"force", TouchProperty::kForce},
    {"altitudeAngle", TouchProperty::kAltitudeAngle},
    {"azimuthAngle", TouchProperty::kAzimuthAngle},
    {"touchType", TouchProperty::kTouchType},
  };
  return propertyMap;
}

JSValueRef kraken::binding::jsc::JSTouchList::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getTouchListPropertyMap();

  if (isNumberIndex(name)) {
    size_t index = std::stoi(name);
    return m_touchList[index]->jsObject;
  } else if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    if (property == TouchListProperty::kLength) {
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

std::vector<JSStringRef> &JSTouchList::getTouchListPropertyNames() {
  static std::vector<JSStringRef> propertyNames {
    JSStringCreateWithUTF8CString("length")
  };
  return propertyNames;
}

const std::unordered_map<std::string, JSTouchList::TouchListProperty> &JSTouchList::getTouchListPropertyMap() {
  static std::unordered_map<std::string, JSTouchList::TouchListProperty> propertyMap {
      {"length", TouchListProperty::kLength}
  };
  return propertyMap;
}

JSTouch::JSTouch(JSContext *context, NativeTouch *touch) : HostObject(context, "Touch"), m_nativeTouch(touch) {}

JSValueRef JSTouch::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getTouchPropertyMap();

  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    switch(property) {
    case kIdentifier:
      return JSValueMakeNumber(ctx, m_nativeTouch->identifier);
    case kTarget:
      return m_nativeTouch->target->instance->object;
    case kClientX:
      return JSValueMakeNumber(ctx, m_nativeTouch->clientX);
    case kClientY:
      return JSValueMakeNumber(ctx, m_nativeTouch->clientY);
    case kScreenX:
      return JSValueMakeNumber(ctx, m_nativeTouch->screenX);
    case kScreenY:
      return JSValueMakeNumber(ctx, m_nativeTouch->screenY);
    case kPageX:
      return JSValueMakeNumber(ctx, m_nativeTouch->pageX);
    case kPageY:
      return JSValueMakeNumber(ctx, m_nativeTouch->pageY);
    case kRadiusX:
      return JSValueMakeNumber(ctx, m_nativeTouch->radiusX);
    case kRadiusY:
      return JSValueMakeNumber(ctx, m_nativeTouch->radiusY);
    case kRotationAngle:
      return JSValueMakeNumber(ctx, m_nativeTouch->rotationAngle);
    case kForce:
      return JSValueMakeNumber(ctx, m_nativeTouch->force);
    case kAltitudeAngle:
      return JSValueMakeNumber(ctx, m_nativeTouch->altitudeAngle);
    case kAzimuthAngle:
      return JSValueMakeNumber(ctx, m_nativeTouch->azimuthAngle);
    case kTouchType:
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
