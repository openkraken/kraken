/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "input_element.h"

namespace kraken::binding::jsc {

void bindInputElement(std::unique_ptr<JSContext> &context) {
  auto InputElement = JSInputElement::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Input", InputElement->classObject);
}

std::unordered_map<JSContext *, JSInputElement *> &JSInputElement::getInstanceMap() {
  static std::unordered_map<JSContext *, JSInputElement *> instanceMap;
  return instanceMap;
}

JSInputElement *JSInputElement::instance(JSContext *context) {
  auto instanceMap = getInstanceMap();
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSInputElement(context);
  }
  return instanceMap[context];
}
JSInputElement::~JSInputElement() {
  auto instanceMap = getInstanceMap();
  instanceMap.erase(context);
}

JSInputElement::JSInputElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSInputElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new InputElementInstance(this);
  return instance->object;
}

JSInputElement::InputElementInstance::InputElementInstance(JSInputElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "input", false), nativeInputElement(new NativeInputElement(nativeElement)) {
  std::string tagName = "input";
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);

  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(eventTargetId, UICommand::createElement, args_01, nativeInputElement);
}

std::vector<JSStringRef> &JSInputElement::InputElementInstance::getInputElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("width"),
    JSStringCreateWithUTF8CString("height"),
    JSStringCreateWithUTF8CString("value"),
    JSStringCreateWithUTF8CString("accept"),
    JSStringCreateWithUTF8CString("autocomplete"),
    JSStringCreateWithUTF8CString("autofocus"),
    JSStringCreateWithUTF8CString("checked"),
    JSStringCreateWithUTF8CString("disabled"),
    JSStringCreateWithUTF8CString("min"),
    JSStringCreateWithUTF8CString("max"),
    JSStringCreateWithUTF8CString("minlength"),
    JSStringCreateWithUTF8CString("maxlength"),
    JSStringCreateWithUTF8CString("size"),
    JSStringCreateWithUTF8CString("multiple"),
    JSStringCreateWithUTF8CString("name"),
    JSStringCreateWithUTF8CString("step"),
    JSStringCreateWithUTF8CString("pattern"),
    JSStringCreateWithUTF8CString("required"),
    JSStringCreateWithUTF8CString("readonly"),
    JSStringCreateWithUTF8CString("placeholder"),
    JSStringCreateWithUTF8CString("type"),
  };
  return propertyNames;
}

const std::unordered_map<std::string, JSInputElement::InputElementInstance::InputProperty> &
JSInputElement::InputElementInstance::getInputElementPropertyMap() {
  static std::unordered_map<std::string, InputProperty> propertyMap{{"width", InputProperty::kWidth},
                                                                    {"height", InputProperty::kHeight},
                                                                    {"value", InputProperty::kValue},
                                                                    {"accept", InputProperty::kAccept},
                                                                    {"autocomplete", InputProperty::kAutocomplete},
                                                                    {"autofocus", InputProperty::kAutofocus},
                                                                    {"checked", InputProperty::kChecked},
                                                                    {"disabled", InputProperty::kDisabled},
                                                                    {"min", InputProperty::kMin},
                                                                    {"max", InputProperty::kMax},
                                                                    {"minlength", InputProperty::kMinlength},
                                                                    {"maxlength", InputProperty::kMaxlength},
                                                                    {"size", InputProperty::kSize},
                                                                    {"multiple", InputProperty::kMultiple},
                                                                    {"name", InputProperty::kName},
                                                                    {"step", InputProperty::kStep},
                                                                    {"pattern", InputProperty::kPattern},
                                                                    {"required", InputProperty::kRequired},
                                                                    {"readonly", InputProperty::kReadonly},
                                                                    {"placeholder", InputProperty::kPlaceholder},
                                                                    {"type", InputProperty::kType},
  };
  return propertyMap;
}

JSValueRef JSInputElement::InputElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getInputElementPropertyMap();
  if (propertyMap.count(name) > 0) {
    getDartMethod()->flushUICommand();

    auto property = propertyMap[name];
    switch (property) {
    case InputProperty::kWidth: {
      return JSValueMakeNumber(_hostClass->ctx, nativeInputElement->getInputWidth(nativeInputElement));
    }
    case InputProperty::kHeight: {
      return JSValueMakeNumber(_hostClass->ctx, nativeInputElement->getInputHeight(nativeInputElement));
    }
    default: {
      return ElementInstance::getStringValueProperty(name);
    }
    }
  }

  return ElementInstance::getProperty(name, exception);
}

void JSInputElement::InputElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getInputElementPropertyMap();
  if (propertyMap.count(name) > 0) {
    JSStringRef stringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);
    std::string string = JSStringToStdString(stringRef);
    NativeString args_01{};
    NativeString args_02{};
    buildUICommandArgs(name, string, args_01, args_02);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
  } else {
    ElementInstance::setProperty(name, value, exception);
  }
}

void JSInputElement::InputElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getInputElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSInputElement::InputElementInstance::~InputElementInstance() {
  delete nativeInputElement;
}

} // namespace kraken::binding::jsc
