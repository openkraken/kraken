/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "object_element.h"
#include "foundation/ui_command_callback_queue.h"

namespace kraken::binding::jsc {

std::unordered_map<JSContext *, JSObjectElement *> JSObjectElement::instanceMap{};

JSObjectElement *JSObjectElement::instance(JSContext *context) {
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSObjectElement(context);
  }
  return instanceMap[context];
}

JSObjectElement::~JSObjectElement() {
  instanceMap.erase(context);
}

JSObjectElement::JSObjectElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSObjectElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                 const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new ObjectElementInstance(this);
  return instance->object;
}

JSObjectElement::ObjectElementInstance::ObjectElementInstance(JSObjectElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "object", false), nativeObjectElement(new NativeObjectElement(nativeElement)) {
  std::string tagName = "object";
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);

  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
      ->registerCommand(eventTargetId, UICommand::createElement, args_01, nativeObjectElement);
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
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case ObjectProperty::kType:
    case ObjectProperty::kCurrentType: {
      return m_type.makeString();
    }
    case ObjectProperty::kData:
    case ObjectProperty::kCurrentData: {
      return m_data.makeString();
    }
    }
  }

  return ElementInstance::getProperty(name, exception);
}

void JSObjectElement::ObjectElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getObjectElementPropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case ObjectProperty::kData: {
      JSStringRef dataStringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);

      m_data.setString(dataStringRef);

      NativeString args_01{};
      NativeString args_02{};

      buildUICommandArgs(name, dataStringRef, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId,UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    case ObjectProperty::kType: {
      JSStringRef typeStringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);
      m_type.setString(typeStringRef);

      NativeString args_01{};
      NativeString args_02{};

      buildUICommandArgs(name, typeStringRef, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId,UICommand::setProperty, args_01, args_02, nullptr);
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
  ::foundation::UICommandCallbackQueue::instance(contextId)->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeObjectElement *>(ptr);
  }, nativeObjectElement);
}

} // namespace kraken::binding::jsc
