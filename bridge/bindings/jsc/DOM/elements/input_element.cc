/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "input_element.h"

namespace kraken::binding::jsc {

void bindInputElement(std::unique_ptr<JSContext> &context) {
  auto InputElement = JSInputElement::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "HTMLInputElement", InputElement->classObject);
}

std::unordered_map<JSContext *, JSInputElement *> JSInputElement::instanceMap {};

JSInputElement *JSInputElement::instance(JSContext *context) {
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSInputElement(context);
  }
  return instanceMap[context];
}
JSInputElement::~JSInputElement() {
  instanceMap.erase(context);
}

JSInputElement::JSInputElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSInputElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new InputElementInstance(this);
  return instance->object;
}

JSValueRef JSInputElement::focus(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef *arguments, JSValueRef *exception) {
  getDartMethod()->flushUICommand();

  auto elementInstance =
    static_cast<JSInputElement::InputElementInstance *>(JSObjectGetPrivate(thisObject));
  assert_m(elementInstance->nativeInputElement->focus != nullptr,
           "Failed to call dart method: focus() is nullptr");
  elementInstance->nativeInputElement->focus(elementInstance->nativeInputElement);
  return nullptr;
}

JSValueRef JSInputElement::blur(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) {
  getDartMethod()->flushUICommand();

  auto elementInstance =
    static_cast<JSInputElement::InputElementInstance *>(JSObjectGetPrivate(thisObject));
  assert_m(elementInstance->nativeInputElement->blur != nullptr,
           "Failed to call dart method: blur() is nullptr");
  elementInstance->nativeInputElement->blur(elementInstance->nativeInputElement);
  return nullptr;
}

JSInputElement::InputElementInstance::InputElementInstance(JSInputElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "input", false), nativeInputElement(new NativeInputElement(nativeElement)) {
  std::string tagName = "input";
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);

  foundation::UICommandBuffer::instance(context->getContextId())
    ->addCommand(eventTargetId, UICommand::createElement, args_01, nativeInputElement);
}

JSValueRef JSInputElement::InputElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = getInputElementPropertyMap();
  auto &propertyPropertyMap = getInputElementPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  if (propertyPropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSInputElement>()->prototypeObject, nameStringHolder.getString(), exception);
  };

  if (propertyMap.count(name) > 0) {
    auto &&property = propertyMap[name];
    switch (property) {
    case InputElementProperty::width: {
      getDartMethod()->flushUICommand();
      return JSValueMakeNumber(_hostClass->ctx, nativeInputElement->getInputWidth(nativeInputElement));
    }
    case InputElementProperty::height: {
      getDartMethod()->flushUICommand();
      return JSValueMakeNumber(_hostClass->ctx, nativeInputElement->getInputHeight(nativeInputElement));
    }
    default: {
      return ElementInstance::getStringValueProperty(name);
    }
    }
  }

  return ElementInstance::getProperty(name, exception);
}

bool JSInputElement::InputElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto &propertyMap = getInputElementPropertyMap();
  auto &prototypePropertyMap = getInputElementPrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) return false;

  if (propertyMap.count(name) > 0) {
    JSStringRef stringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);
    std::string string = JSStringToStdString(stringRef);
    NativeString args_01{};
    NativeString args_02{};
    buildUICommandArgs(name, string, args_01, args_02);
    foundation::UICommandBuffer::instance(_hostClass->contextId)
      ->addCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
    return true;
  } else {
    return ElementInstance::setProperty(name, value, exception);
  }
}

void JSInputElement::InputElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getInputElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (auto &property : getInputElementPrototypePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSInputElement::InputElementInstance::~InputElementInstance() {
  delete nativeInputElement;
}

} // namespace kraken::binding::jsc
