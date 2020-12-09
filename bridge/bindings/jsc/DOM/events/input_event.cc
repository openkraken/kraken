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

JSInputEvent *JSInputEvent::instance(JSContext *context) {
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSInputEvent(context);
  }
  return instanceMap[context];
}

JSInputEvent::~JSInputEvent() {
  instanceMap.erase(context);
}

JSInputEvent::JSInputEvent(JSContext *context) : JSEvent(context, "InputEvent") {}

JSObjectRef JSInputEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                              const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    JSC_THROW_ERROR(ctx, "Failed to construct 'JSInputEvent': 1 argument required, but only 0 present.", exception);
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
  auto propertyMap = JSInputEvent::getInputEventPropertyMap();

  if (propertyMap.count(name) == 0) return EventInstance::getProperty(name, exception);

  auto property = propertyMap[name];
  if (property == JSInputEvent::InputEventProperty::kInputType) {
    return m_inputType.makeString();
  } else if (property == JSInputEvent::InputEventProperty::kData) {
    return m_data.makeString();
  }

  return nullptr;
}

void InputEventInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSInputEvent::getInputEventPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case JSInputEvent::InputEventProperty::kInputType: {
      JSStringRef str = JSValueToStringCopy(ctx, value, exception);
      m_inputType.setString(str);
      break;
    }
    case JSInputEvent::InputEventProperty::kData: {
      JSStringRef str = JSValueToStringCopy(ctx, value, exception);
      m_data.setString(str);
      break;
    }
    }
  } else {
    EventInstance::setProperty(name, value, exception);
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

std::vector<JSStringRef> &JSInputEvent::getInputEventPropertyNames() {
  static std::vector<JSStringRef> propertyNames{JSStringCreateWithUTF8CString("data"),
                                                JSStringCreateWithUTF8CString("inputType")};
  return propertyNames;
}

const std::unordered_map<std::string, JSInputEvent::InputEventProperty> &JSInputEvent::getInputEventPropertyMap() {
  static std::unordered_map<std::string, InputEventProperty> propertyMap{{"data", InputEventProperty::kData},
                                                                         {"inputType", InputEventProperty::kInputType}};
  return propertyMap;
}

} // namespace kraken::binding::jsc
