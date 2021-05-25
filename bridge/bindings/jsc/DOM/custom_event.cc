/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "custom_event.h"

#include <utility>

namespace kraken::binding::jsc {

void bindCustomEvent(std::unique_ptr<JSContext> &context) {
  auto CustomEvent = JSCustomEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "CustomEvent", CustomEvent->classObject);
};

std::unordered_map<JSContext *, JSCustomEvent *> JSCustomEvent::instanceMap{};

JSCustomEvent::~JSCustomEvent() {
  instanceMap.erase(context);
}

JSCustomEvent::JSCustomEvent(JSContext *context) : JSEvent(context, "CustomEvent") {}

JSObjectRef JSCustomEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to construct 'CustomEvent': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef typeArgsStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  JSValueRef customEventInit = nullptr;
  if (argumentCount == 2) {
    customEventInit = arguments[1];
  }
  std::string &&customEventType = JSStringToStdString(typeArgsStringRef);
  auto customEvent = new CustomEventInstance(JSCustomEvent::instance(context), customEventType, customEventInit, exception);
  return customEvent->object;
}

JSValueRef JSCustomEvent::getProperty(std::string &name, JSValueRef *exception) {
  return JSEvent::getProperty(name, exception);
}

CustomEventInstance::CustomEventInstance(JSCustomEvent *jsCustomEvent, std::string eventType, JSValueRef eventInitValue, JSValueRef *exception)
  : EventInstance(jsCustomEvent, std::move(eventType), eventInitValue, exception) {
  if (eventInitValue != nullptr) {
    JSObjectRef eventInit = JSValueToObject(ctx, eventInitValue, exception);

    if (objectHasProperty(ctx, "detail", eventInit)) {
      m_detail.setValue(getObjectPropertyValue(ctx, "detail", eventInit, exception));
    }
  }
}

CustomEventInstance::CustomEventInstance(JSCustomEvent *jsCustomEvent, NativeCustomEvent* nativeCustomEvent)
  : nativeCustomEvent(nativeCustomEvent)
    , EventInstance(jsCustomEvent, nativeCustomEvent->nativeEvent) {
  JSStringRef ref = JSStringCreateWithCharacters(nativeCustomEvent->detail->string, nativeCustomEvent->detail->length);
  nativeCustomEvent->detail->free();
  m_detail.setValue(JSValueMakeString(context->context(), ref));
}

JSValueRef CustomEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = JSCustomEvent::getCustomEventPropertyMap();
  auto &prototypePropertyMap = JSCustomEvent::getCustomEventPrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) {
    JSStringHolder nameStringHolder = JSStringHolder(context, name);
    return JSObjectGetProperty(ctx, prototype<JSCustomEvent>()->prototypeObject, nameStringHolder.getString(), exception);
  };

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);
  auto &property = propertyMap[name];

  switch (property) {
  case JSCustomEvent::CustomEventProperty::detail:
    return m_detail.value();
  }

  return nullptr;
}

bool CustomEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto &propertyMap = JSCustomEvent::getCustomEventPropertyMap();
  auto &prototypePropertyMap = JSCustomEvent::getCustomEventPrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) return false;

  if (propertyMap.count(name) > 0) {
    auto &property = propertyMap[name];

    if (property == JSCustomEvent::CustomEventProperty::detail) {
      m_detail.setValue(value);
    }
    return true;
  } else {
    return EventInstance::setProperty(name, value, exception);
  }
}

JSValueRef JSCustomEvent::initCustomEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                size_t argumentCount, const JSValueRef *arguments,
                                                JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to execute 'initCustomEvent' on 'CustomEvent': 1 argument required, but only 0 present", exception);
    return nullptr;
  }
  auto eventInstance = static_cast<CustomEventInstance *>(JSObjectGetPrivate(thisObject));

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

CustomEventInstance::~CustomEventInstance() {}

void CustomEventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventInstance::getPropertyNames(accumulator);

  for (auto &property : JSCustomEvent::getCustomEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (auto &property : JSCustomEvent::getCustomEventPrototypePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
