/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "object_element.h"

namespace kraken::binding::jsc {

std::unordered_map<JSContext *, JSObjectElement *> JSObjectElement::instanceMap{};

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

JSValueRef JSObjectElement::ObjectElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getObjectElementPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case ObjectElementProperty::type:
    case ObjectElementProperty::currentType: {
      return m_type.makeString();
    }
    case ObjectElementProperty::data:
    case ObjectElementProperty::currentData: {
      return m_data.makeString();
    }
    }
  }

  return ElementInstance::getProperty(name, exception);
}

bool JSObjectElement::ObjectElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getObjectElementPropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case ObjectElementProperty::data: {
      JSStringRef dataStringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);

      m_data.setString(dataStringRef);

      NativeString args_01{};
      NativeString args_02{};

      buildUICommandArgs(name, dataStringRef, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId,UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    case ObjectElementProperty::type: {
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
    return true;
  } else {
    return ElementInstance::setProperty(name, value, exception);
  }
}

void JSObjectElement::ObjectElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getObjectElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSObjectElement::ObjectElementInstance::~ObjectElementInstance() {
  ::foundation::UICommandCallbackQueue::instance()->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeObjectElement *>(ptr);
  }, nativeObjectElement);
}

} // namespace kraken::binding::jsc
