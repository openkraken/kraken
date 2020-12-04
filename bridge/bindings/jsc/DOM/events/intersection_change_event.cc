/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "intersection_change_event.h"

namespace kraken::binding::jsc {

void bindIntersectionChangeEvent(std::unique_ptr<JSContext> &context) {
  auto event = JSIntersectionChangeEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "IntersectionChangeEvent", event->classObject);
};

std::unordered_map<JSContext *, JSIntersectionChangeEvent *> JSIntersectionChangeEvent::instanceMap{};

JSIntersectionChangeEvent *JSIntersectionChangeEvent::instance(JSContext *context) {
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSIntersectionChangeEvent(context);
  }
  return instanceMap[context];
}

JSIntersectionChangeEvent::~JSIntersectionChangeEvent() {
  instanceMap.erase(context);
}

JSIntersectionChangeEvent::JSIntersectionChangeEvent(JSContext *context)
  : JSEvent(context, "IntersectionChangeEvent") {}

JSObjectRef JSIntersectionChangeEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor,
                                                           size_t argumentCount, const JSValueRef *arguments,
                                                           JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to construct 'JSIntersectionChangeEvent': 1 argument required, but only 0 present.",
                    exception);
    return nullptr;
  }

  JSStringRef dataStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  auto event = new IntersectionChangeEventInstance(this, dataStringRef);
  return event->object;
}

JSValueRef JSIntersectionChangeEvent::getProperty(std::string &name, JSValueRef *exception) {
  return nullptr;
}

IntersectionChangeEventInstance::IntersectionChangeEventInstance(
  JSIntersectionChangeEvent *jsIntersectionChangeEvent, NativeIntersectionChangeEvent *nativeIntersectionChangeEvent)
  : EventInstance(jsIntersectionChangeEvent, nativeIntersectionChangeEvent->nativeEvent),
    nativeIntersectionChangeEvent(nativeIntersectionChangeEvent) {
  intersectionRatio = nativeIntersectionChangeEvent->intersectionRatio;
}

IntersectionChangeEventInstance::IntersectionChangeEventInstance(JSIntersectionChangeEvent *jsIntersectionChangeEvent,
                                                                 JSStringRef data)
  : EventInstance(jsIntersectionChangeEvent, "intersectionchange", nullptr, nullptr) {
  nativeIntersectionChangeEvent = new NativeIntersectionChangeEvent(nativeEvent);
}

JSValueRef IntersectionChangeEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSIntersectionChangeEvent::getIntersectionChangeEventPropertyMap();

  if (!propertyMap.contains(name)) return EventInstance::getProperty(name, exception);

  auto property = propertyMap[name];
  if (property == JSIntersectionChangeEvent::IntersectionChangeEventProperty::kIntersectionRatio) {
    return JSValueMakeNumber(ctx, intersectionRatio);
  }

  return nullptr;
}

void IntersectionChangeEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSIntersectionChangeEvent::getIntersectionChangeEventPropertyMap();
  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    if (property == JSIntersectionChangeEvent::IntersectionChangeEventProperty::kIntersectionRatio) {
      intersectionRatio = JSValueToNumber(ctx, value, exception);
    }
  } else {
    EventInstance::setProperty(name, value, exception);
  }
}

IntersectionChangeEventInstance::~IntersectionChangeEventInstance() {
  delete nativeIntersectionChangeEvent;
}

void IntersectionChangeEventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventInstance::getPropertyNames(accumulator);

  for (auto &property : JSIntersectionChangeEvent::getIntersectionChangeEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::vector<JSStringRef> &JSIntersectionChangeEvent::getIntersectionChangeEventPropertyNames() {
  static std::vector<JSStringRef> propertyNames{JSStringCreateWithUTF8CString("intersectionRatio"),};
  return propertyNames;
}

const std::unordered_map<std::string, JSIntersectionChangeEvent::IntersectionChangeEventProperty> &
JSIntersectionChangeEvent::getIntersectionChangeEventPropertyMap() {
  static std::unordered_map<std::string, IntersectionChangeEventProperty> propertyMap{
    {"intersectionRatio", IntersectionChangeEventProperty::kIntersectionRatio}};
  return propertyMap;
}

} // namespace kraken::binding::jsc
