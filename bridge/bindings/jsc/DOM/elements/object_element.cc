/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "object_element.h"

namespace kraken::binding::jsc {

JSObjectElement *JSObjectElement::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSObjectElement *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSObjectElement(context);
  }
  return instanceMap[context];
}

JSObjectElement::JSObjectElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSObjectElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                 const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new ObjectElementInstance(this);
  return instance->object;
}

JSObjectElement::ObjectElementInstance::ObjectElementInstance(JSObjectElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "object"), nativeObjectElement(new NativeObjectElement(nativeElement)) {
  std::string tagName = "object";

  auto args = buildUICommandArgs(tagName);
  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(eventTargetId, UICommandType::createElement, args, 1, nativeObjectElement);
}

std::vector<JSStringRef> &JSObjectElement::ObjectElementInstance::getObjectElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("data"),
    JSStringCreateWithUTF8CString("currentData"),
    JSStringCreateWithUTF8CString("type"),
    JSStringCreateWithUTF8CString("currentType")
  };
  return propertyNames;
}

const std::unordered_map<std::string, JSObjectElement::ObjectElementInstance::ObjectProperty> &
JSObjectElement::ObjectElementInstance::getObjectElementPropertyMap() {
  static std::unordered_map<std::string, ObjectProperty> propertyMap{{"data", ObjectProperty::kData},
                                                                     {"currentData", ObjectProperty::kCurrentData},
                                                                     {"currentType", ObjectProperty::kCurrentType},
                                                                     {"type", ObjectProperty::kType}};
  return propertyMap;
}

JSValueRef JSObjectElement::ObjectElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getObjectElementPropertyMap();
  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];
    switch (property) {
    case ObjectProperty::kType:
    case ObjectProperty::kCurrentType: {
      return JSValueMakeString(_hostClass->ctx, _type);
    }
    case ObjectProperty::kData:
    case ObjectProperty::kCurrentData: {
      return JSValueMakeString(_hostClass->ctx, _data);
    }
    }
  }

  return ElementInstance::getProperty(name, exception);
}

void JSObjectElement::ObjectElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getObjectElementPropertyMap();

  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];
    switch (property) {
    case ObjectProperty::kData: {
      _data = JSValueToStringCopy(_hostClass->ctx, value, exception);
      JSStringRetain(_data);

      auto args = buildUICommandArgs(name, JSStringRetain(_data));
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
      break;
    }
    case ObjectProperty::kType: {
      _type = JSValueToStringCopy(_hostClass->ctx, value, exception);
      JSStringRetain(_type);

      auto args = buildUICommandArgs(name, JSStringRetain(_type));
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
      break;
    }
    default:
      break;
    }
  } else {
    ElementInstance::setProperty(name, value, exception);
  }
}

void JSObjectElement::ObjectElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getObjectElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSObjectElement::ObjectElementInstance::~ObjectElementInstance() {
  delete nativeObjectElement;
}

} // namespace kraken::binding::jsc
