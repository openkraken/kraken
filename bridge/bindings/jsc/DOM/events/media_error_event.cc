/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "media_error_event.h"

namespace kraken::binding::jsc {

void bindMediaErrorEvent(std::unique_ptr<JSContext> &context) {
  auto event = JSMediaErrorEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "MediaErrorEvent", event->classObject);
};

std::unordered_map<JSContext *, JSMediaErrorEvent *> & JSMediaErrorEvent::getInstanceMap() {
  static std::unordered_map<JSContext *, JSMediaErrorEvent *> instanceMap;
  return instanceMap;
}

JSMediaErrorEvent *JSMediaErrorEvent::instance(JSContext *context) {
  auto instanceMap = getInstanceMap();
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSMediaErrorEvent(context);
  }
  return instanceMap[context];
}

JSMediaErrorEvent::~JSMediaErrorEvent() {
  auto instanceMap = getInstanceMap();
  instanceMap.erase(context);
}

JSMediaErrorEvent::JSMediaErrorEvent(JSContext *context) : JSEvent(context, "MediaErrorEvent") {}

JSObjectRef JSMediaErrorEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                              const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to construct 'JSMediaErrorEvent': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef dataStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  auto event = new MediaErrorEventInstance(this, dataStringRef);
  return event->object;
}

JSValueRef JSMediaErrorEvent::getProperty(std::string &name, JSValueRef *exception) {
  return nullptr;
}

MediaErrorEventInstance::MediaErrorEventInstance(JSMediaErrorEvent *jsMediaErrorEvent, NativeMediaErrorEvent *nativeMediaErrorEvent)
  : EventInstance(jsMediaErrorEvent, nativeMediaErrorEvent->nativeEvent), nativeMediaErrorEvent(nativeMediaErrorEvent) {
  if (nativeMediaErrorEvent->code != 0) code = nativeMediaErrorEvent->code;
  if (nativeMediaErrorEvent->message != nullptr) m_message.setString(nativeMediaErrorEvent->message);
}

MediaErrorEventInstance::MediaErrorEventInstance(JSMediaErrorEvent *jsMediaErrorEvent, JSStringRef data)
  : EventInstance(jsMediaErrorEvent, "error", nullptr, nullptr) {
  nativeMediaErrorEvent = new NativeMediaErrorEvent(nativeEvent);
}

JSValueRef MediaErrorEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSMediaErrorEvent::getMediaErrorEventPropertyMap();

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);

  auto property = propertyMap[name];

  if (property == JSMediaErrorEvent::MediaErrorEventProperty::kCode) {
    return JSValueMakeNumber(ctx, code);
  } else if (property == JSMediaErrorEvent::MediaErrorEventProperty::kMessage) {
    return m_message.makeString();
  }

  return nullptr;
}

void MediaErrorEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSMediaErrorEvent::getMediaErrorEventPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case JSMediaErrorEvent::MediaErrorEventProperty::kMessage: {
      JSStringRef str = JSValueToStringCopy(ctx, value, exception);
      m_message.setString(str);
      break;
    }
    case JSMediaErrorEvent::MediaErrorEventProperty::kCode: {
      code = JSValueToNumber(ctx, value, exception);
      break;
    }
    }
  } else {
    EventInstance::setProperty(name, value, exception);
  }
}

MediaErrorEventInstance::~MediaErrorEventInstance() {
  nativeMediaErrorEvent->message->free();
  delete nativeMediaErrorEvent;
}

void MediaErrorEventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventInstance::getPropertyNames(accumulator);

  for (auto &property : JSMediaErrorEvent::getMediaErrorEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::vector<JSStringRef> &JSMediaErrorEvent::getMediaErrorEventPropertyNames() {
  static std::vector<JSStringRef> propertyNames{JSStringCreateWithUTF8CString("code"),
                                                JSStringCreateWithUTF8CString("message")};
  return propertyNames;
}

const std::unordered_map<std::string, JSMediaErrorEvent::MediaErrorEventProperty> &JSMediaErrorEvent::getMediaErrorEventPropertyMap() {
  static std::unordered_map<std::string, MediaErrorEventProperty> propertyMap{{"code", MediaErrorEventProperty::kCode},
                                                                         {"message", MediaErrorEventProperty::kMessage}};
  return propertyMap;
}

} // namespace kraken::binding::jsc
