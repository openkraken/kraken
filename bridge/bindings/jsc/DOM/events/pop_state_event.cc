/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "pop_state_event.h"

#include <utility>

namespace kraken::binding::jsc {

// https://html.spec.whatwg.org/multipage/browsing-the-web.html#the-popstateevent-interface
void bindPopStateEvent(std::unique_ptr<JSContext> &context) {
  auto PopStateEvent = JSPopStateEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "PopStateEvent", PopStateEvent->classObject);
};

std::unordered_map<JSContext *, JSPopStateEvent *> JSPopStateEvent::instanceMap{};

JSPopStateEvent::~JSPopStateEvent() {
  instanceMap.erase(context);
}

JSPopStateEvent::JSPopStateEvent(JSContext *context) : JSEvent(context, "PopStateEvent") {}

JSObjectRef JSPopStateEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                              const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to construct 'PopStateEvent': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef typeArgsStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  JSValueRef PopStateEventInit = nullptr;
  if (argumentCount == 2) {
    PopStateEventInit = arguments[1];
  }
  std::string &&PopStateEventType = JSStringToStdString(typeArgsStringRef);
  auto PopStateEvent =
    new PopStateEventInstance(JSPopStateEvent::instance(context), PopStateEventType, PopStateEventInit, exception);
  return PopStateEvent->object;
}

JSValueRef JSPopStateEvent::getProperty(std::string &name, JSValueRef *exception) {
  return JSEvent::getProperty(name, exception);
}

PopStateEventInstance::PopStateEventInstance(JSPopStateEvent *jsPopStateEvent, std::string eventType,
                                       JSValueRef eventInitValue, JSValueRef *exception)
  : EventInstance(jsPopStateEvent, std::move(eventType), eventInitValue, exception) {
  if (eventInitValue != nullptr) {
    JSObjectRef eventInit = JSValueToObject(ctx, eventInitValue, exception);

    if (objectHasProperty(ctx, "state", eventInit)) {
      m_state.setValue(getObjectPropertyValue(ctx, "state", eventInit, exception));
    }
  }
}

PopStateEventInstance::PopStateEventInstance(JSPopStateEvent *jsPopStateEvent, NativePopStateEvent *nativePopStateEvent)
  : nativePopStateEvent(nativePopStateEvent), EventInstance(jsPopStateEvent, nativePopStateEvent->nativeEvent) {
  m_state.setValue(nativePopStateEvent->state);
}

JSValueRef PopStateEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSPopStateEvent::getPopStateEventPropertyMap();
  auto prototypePropertyMap = JSPopStateEvent::getPopStateEventPrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSEventTarget>()->prototypeObject,
                               JSStringCreateWithUTF8CString(name.c_str()), exception);
  }

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);
  auto property = propertyMap[name];

  switch (property) {
  case JSPopStateEvent::PopStateEventProperty::state:
    return m_state.value();
  }

  return nullptr;
}

bool PopStateEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSPopStateEvent::getPopStateEventPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case JSPopStateEvent::PopStateEventProperty::state:
      m_state.setValue(value);
    }

    return true;
  } else {
    return EventInstance::setProperty(name, value, exception);
  }
}

JSValueRef JSPopStateEvent::initPopStateEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to execute 'initPopStateEvent' on 'PopStateEvent': 1 argument required, but only 0 present",
                 exception);
    return nullptr;
  }
  auto eventInstance = static_cast<PopStateEventInstance *>(JSObjectGetPrivate(thisObject));

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

  return nullptr;
}

PopStateEventInstance::~PopStateEventInstance() {}

void PopStateEventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventInstance::getPropertyNames(accumulator);

  for (auto &property : JSPopStateEvent::getPopStateEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
