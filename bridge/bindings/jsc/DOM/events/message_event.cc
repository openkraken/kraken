/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "message_event.h"

#include "media_error_event.h"

namespace kraken::binding::jsc {

void bindMessageEvent(std::unique_ptr<JSContext> &context) {
  auto event = JSMessageEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "MessageEvent", event->classObject);
};

std::unordered_map<JSContext *, JSMessageEvent *> JSMessageEvent::instanceMap{};

JSMessageEvent::~JSMessageEvent() {
  instanceMap.erase(context);
}

JSMessageEvent::JSMessageEvent(JSContext *context) : JSEvent(context, "MessageEvent") {}

JSObjectRef JSMessageEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 0) {
    throwJSError(ctx, "Failed to construct 'JSMessageEvent': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef eventTypeStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string eventType = JSStringToStdString(eventTypeStringRef);
  JSValueRef dataRef = arguments[1];
  auto event = new MessageEventInstance(this, eventType, dataRef);
  return event->object;
}

JSValueRef JSMessageEvent::getProperty(std::string &name, JSValueRef *exception) {
  return nullptr;
}

MessageEventInstance::MessageEventInstance(JSMessageEvent *jsMessageEvent, NativeMessageEvent *nativeMessageEvent)
  : EventInstance(jsMessageEvent, nativeMessageEvent->nativeEvent), nativeMessageEvent(nativeMessageEvent) {
  if (nativeMessageEvent->data != nullptr) {
    JSStringRef dataRef = JSStringCreateWithCharacters(nativeMessageEvent->data->string, nativeMessageEvent->data->length);

    m_data.setString(JSValueCreateJSONString(ctx, JSValueMakeString(ctx, dataRef), 0, nullptr));
  }
  if (nativeMessageEvent->origin != nullptr) m_origin.setString(nativeMessageEvent->origin);
}

MessageEventInstance::MessageEventInstance(JSMessageEvent *jsMessageEvent, std::string eventType, JSValueRef data, JSValueRef origin)
  : EventInstance(jsMessageEvent, eventType, nullptr, nullptr) {
  nativeMessageEvent = new NativeMessageEvent(nativeEvent);

  if (data != nullptr && !JSValueIsUndefined(ctx, data)) {
    JSStringRef dataStringRef = JSValueCreateJSONString(ctx, data, 0 ,nullptr);
    if (dataStringRef != nullptr) {
      m_data.setString(dataStringRef);
    }
  }

  if (origin != nullptr && !JSValueIsUndefined(ctx, origin)) {
    JSStringRef originStringRef = JSValueToStringCopy(ctx, origin, nullptr);
    if (originStringRef != nullptr) {
      m_origin.setString(originStringRef);
    }
  }
}

MessageEventInstance::MessageEventInstance(JSMessageEvent *jsMessageEvent, std::string eventType, JSValueRef eventInitValueRef)
  : EventInstance(jsMessageEvent, eventType, nullptr, nullptr) {
  nativeMessageEvent = new NativeMessageEvent(nativeEvent);

  JSObjectRef eventInitObjRef = JSValueToObject(ctx, eventInitValueRef, nullptr);

  JSStringRef strData = JSStringCreateWithUTF8CString("data");
  JSValueRef data = JSObjectGetProperty(ctx, eventInitObjRef, strData, nullptr);

  if (data != nullptr && !JSValueIsUndefined(ctx, data)) {
    m_data.setString(JSValueCreateJSONString(ctx, data, 0 ,nullptr));
  }

  JSStringRef strOrigin = JSStringCreateWithUTF8CString("origin");
  JSValueRef origin = JSObjectGetProperty(ctx, eventInitObjRef, strOrigin, nullptr);

  if (origin != nullptr && !JSValueIsUndefined(ctx, origin)) {
    m_origin.setString(JSValueToStringCopy(ctx, origin, nullptr));
  }
}

JSValueRef MessageEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = JSMessageEvent::getMessageEventPropertyMap();

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);

  auto &property = propertyMap[name];

  switch(property) {
  case JSMessageEvent::MessageEventProperty::data:
    return JSValueMakeFromJSONString(ctx, m_data.getString());
  case JSMessageEvent::MessageEventProperty::origin:
    return m_origin.makeString();
  }

  return nullptr;
}

bool MessageEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto &propertyMap = JSMessageEvent::getMessageEventPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto &property = propertyMap[name];

    switch(property) {
    case JSMessageEvent::MessageEventProperty::data: {
      JSStringRef str = JSValueToStringCopy(ctx, value, exception);
      m_data.setString(str);
      break;
    }
    case JSMessageEvent::MessageEventProperty::origin: {
      JSStringRef str = JSValueToStringCopy(ctx, value, exception);
      m_origin.setString(str);
      break;
    }
    }
    return true;
  } else {
    return EventInstance::setProperty(name, value, exception);
  }
}

MessageEventInstance::~MessageEventInstance() {
  if (nativeMessageEvent != nullptr) {
    if (nativeMessageEvent->data->string != nullptr) {
      nativeMessageEvent->data->free();
    }
    if (nativeMessageEvent->origin->string != nullptr) {
      nativeMessageEvent->origin->free();
    }
    delete nativeMessageEvent;
  }
}

void MessageEventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventInstance::getPropertyNames(accumulator);

  for (auto &property : JSMessageEvent::getMessageEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
