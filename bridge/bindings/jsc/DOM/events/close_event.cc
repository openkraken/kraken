/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "close_event.h"

namespace kraken::binding::jsc {

void bindCloseEvent(std::unique_ptr<JSContext> &context) {
  auto event = JSCloseEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "CloseEvent", event->classObject);
};

std::unordered_map<JSContext *, JSCloseEvent *> JSCloseEvent::instanceMap{};

JSCloseEvent::~JSCloseEvent() {
  instanceMap.erase(context);
}

JSCloseEvent::JSCloseEvent(JSContext *context) : JSEvent(context, "CloseEvent") {}

JSObjectRef JSCloseEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                              const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to construct 'JSCloseEvent': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef dataStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  JSValueRef closeEventInit = nullptr;
  if (argumentCount == 2) {
    closeEventInit = arguments[1];
  }

  auto event = new CloseEventInstance(this, dataStringRef, closeEventInit, exception);

  return event->object;
}

JSValueRef JSCloseEvent::getProperty(std::string &name, JSValueRef *exception) {
  return nullptr;
}

CloseEventInstance::CloseEventInstance(JSCloseEvent *jsCloseEvent, NativeCloseEvent *nativeCloseEvent)
  : EventInstance(jsCloseEvent, nativeCloseEvent->nativeEvent), nativeCloseEvent(nativeCloseEvent) {
  code = nativeCloseEvent->code;
  m_reason.setString(nativeCloseEvent->reason);
  wasClean = nativeCloseEvent->wasClean == 1;
}

CloseEventInstance::CloseEventInstance(JSCloseEvent *jsCloseEvent, JSStringRef data, JSValueRef closeEventInit, JSValueRef *exception)
  : EventInstance(jsCloseEvent, "close", closeEventInit, exception) {
  nativeCloseEvent = new NativeCloseEvent(nativeEvent);

  if (closeEventInit != nullptr) {
    JSObjectRef eventInit = JSValueToObject(ctx, closeEventInit, exception);
    if (objectHasProperty(ctx, "wasClean", eventInit)) {
      nativeCloseEvent->wasClean = JSValueToBoolean(ctx, getObjectPropertyValue(ctx, "wasClean", eventInit, exception)) ? 1 : 0;
    }
    if (objectHasProperty(ctx, "code", eventInit)) {
      nativeCloseEvent->code = JSValueToNumber(ctx, getObjectPropertyValue(ctx, "code", eventInit, exception), exception);
    }
    if (objectHasProperty(ctx, "reason", eventInit)) {
      nativeCloseEvent->reason = stringRefToNativeString(JSValueToStringCopy(ctx, getObjectPropertyValue(ctx, "reason", eventInit, exception), exception));
    }
  }
}

JSValueRef CloseEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = JSCloseEvent::getCloseEventPropertyMap();

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);

  auto &property = propertyMap[name];
  switch(property) {
  case JSCloseEvent::CloseEventProperty::code:
    return JSValueMakeNumber(ctx, code);
  case JSCloseEvent::CloseEventProperty::reason:
    return m_reason.makeString();
  case JSCloseEvent::CloseEventProperty::wasClean:
    return JSValueMakeBoolean(ctx, wasClean);
  }

  return nullptr;
}

bool CloseEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto &propertyMap = JSCloseEvent::getCloseEventPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto &property = propertyMap[name];

    switch (property) {

    case JSCloseEvent::CloseEventProperty::code: {
      code = JSValueToNumber(ctx, value, exception);
      break;
    }
    case JSCloseEvent::CloseEventProperty::reason: {
      JSStringRef str = JSValueToStringCopy(ctx, value, exception);
      m_reason.setString(str);
      break;
    }
    case JSCloseEvent::CloseEventProperty::wasClean: {
      wasClean = JSValueToBoolean(ctx, value);
      break;
    }
    }
    return true;
  } else {
    return EventInstance::setProperty(name, value, exception);
  }
}

CloseEventInstance::~CloseEventInstance() {
  nativeCloseEvent->reason->free();
  delete nativeCloseEvent;
}

void CloseEventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventInstance::getPropertyNames(accumulator);

  for (auto &property : JSCloseEvent::getCloseEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
