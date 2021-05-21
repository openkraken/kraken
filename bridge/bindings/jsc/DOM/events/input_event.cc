/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "input_event.h"

namespace kraken::binding::jsc {

void bindInputEvent(std::unique_ptr<JSContext> &context) {
  auto event = JSInputEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "InputEvent", event->classObject);
};

std::unordered_map<JSContext *, JSInputEvent *> JSInputEvent::instanceMap{};

JSInputEvent::~JSInputEvent() {
  instanceMap.erase(context);
}

JSInputEvent::JSInputEvent(JSContext *context) : JSEvent(context, "InputEvent") {}

JSObjectRef JSInputEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                              const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to construct 'JSInputEvent': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef dataStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  JSValueRef inputEventInit = nullptr;
  if (argumentCount == 2) {
    inputEventInit = arguments[1];
  }
  auto event = new InputEventInstance(this, dataStringRef, inputEventInit, exception);
  return event->object;
}

JSValueRef JSInputEvent::getProperty(std::string &name, JSValueRef *exception) {
  return nullptr;
}

InputEventInstance::InputEventInstance(JSInputEvent *jsInputEvent, NativeInputEvent *nativeInputEvent)
  : EventInstance(jsInputEvent, nativeInputEvent->nativeEvent), nativeInputEvent(nativeInputEvent) {
  if (nativeInputEvent->data != nullptr) m_data.setString(nativeInputEvent->data);
  if (nativeInputEvent->inputType != nullptr) m_inputType.setString(nativeInputEvent->inputType);
}

InputEventInstance::InputEventInstance(JSInputEvent *jsInputEvent, JSStringRef data, JSValueRef inputEventInitRef,
                                       JSValueRef *exception)
  : EventInstance(jsInputEvent, "input", inputEventInitRef, exception) {
  nativeInputEvent = new NativeInputEvent(nativeEvent);

  if (inputEventInitRef != nullptr) {
    JSObjectRef inputInit = JSValueToObject(ctx, inputEventInitRef, exception);
    if (objectHasProperty(ctx, "inputType", inputInit)) {
      nativeInputEvent->inputType = stringRefToNativeString(
        JSValueToStringCopy(ctx, getObjectPropertyValue(ctx, "inputType", inputInit, exception), exception));
    }

    if (objectHasProperty(ctx, "data", inputInit)) {
      nativeInputEvent->data = stringRefToNativeString(
        JSValueToStringCopy(ctx, getObjectPropertyValue(ctx, "data", inputInit, exception), exception));
    }
  }
}

JSValueRef InputEventInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = JSInputEvent::getInputEventPropertyMap();

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);

  auto &property = propertyMap[name];
  if (property == JSInputEvent::InputEventProperty::inputType) {
    return m_inputType.makeString();
  } else if (property == JSInputEvent::InputEventProperty::data) {
    return m_data.makeString();
  }

  return nullptr;
}

bool InputEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto &propertyMap = JSInputEvent::getInputEventPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto &property = propertyMap[name];

    switch (property) {
    case JSInputEvent::InputEventProperty::inputType: {
      JSStringRef str = JSValueToStringCopy(ctx, value, exception);
      m_inputType.setString(str);
      break;
    }
    case JSInputEvent::InputEventProperty::data: {
      JSStringRef str = JSValueToStringCopy(ctx, value, exception);
      m_data.setString(str);
      break;
    }
    }
    return true;
  } else {
    return EventInstance::setProperty(name, value, exception);
  }
}

InputEventInstance::~InputEventInstance() {
  nativeInputEvent->data->free();
  nativeInputEvent->inputType->free();
  delete nativeInputEvent;
}

void InputEventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventInstance::getPropertyNames(accumulator);

  for (auto &property : JSInputEvent::getInputEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
