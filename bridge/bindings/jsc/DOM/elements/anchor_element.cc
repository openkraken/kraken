/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "anchor_element.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

JSAnchorElement::JSAnchorElement(JSContext *context) : JSElement(context) {}

JSAnchorElement *JSAnchorElement::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSAnchorElement *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSAnchorElement(context);
  }
  return instanceMap[context];
}

JSObjectRef JSAnchorElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                 const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new AnchorElementInstance(this);
  return instance->object;
}

JSAnchorElement::AnchorElementInstance::AnchorElementInstance(JSAnchorElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "a"), nativeAnchorElement(new NativeAnchorElement(nativeElement)) {
  JSStringRef canvasTagNameStringRef = JSStringCreateWithUTF8CString("a");
  NativeString tagName{};
  tagName.string = JSStringGetCharactersPtr(canvasTagNameStringRef);
  tagName.length = JSStringGetLength(canvasTagNameStringRef);

  const int32_t argsLength = 1;
  auto **args = new NativeString *[argsLength];
  args[0] = tagName.clone();

  foundation::UICommandTaskMessageQueue::instance(_hostClass->context->getContextId())
      ->registerCommand(eventTargetId, UICommandType::createElement, args, argsLength, nativeAnchorElement);
}

JSValueRef JSAnchorElement::AnchorElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getAnchorElementPropertyMap();
  auto property = propertyMap[name];

  if (property == AnchorElementProperty::kHref) {
    return JSValueMakeString(_hostClass->ctx, _href);
  } else if (property == AnchorElementProperty::kTarget) {
    return JSValueMakeString(_hostClass->ctx, _target);
  }

  return ElementInstance::getProperty(name, exception);
}

void JSAnchorElement::AnchorElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getAnchorElementPropertyMap();
  auto property = propertyMap[name];
  if (property == AnchorElementProperty::kHref) {
    NativeString **args = new NativeString *[2];
    JSStringRef hrefValueStringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(hrefValueStringRef);
    _href = hrefValueStringRef;

    std::string hrefValueString = JSStringToStdString(hrefValueStringRef);

    ELEMENT_SET_PROPERTY(name.c_str(), hrefValueString.c_str(), args);

    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
  } else if (property == AnchorElementProperty::kTarget) {
    NativeString **args = new NativeString *[2];

    JSStringRef targetValueStringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(targetValueStringRef);
    _target = targetValueStringRef;

    std::string targetValueString = JSStringToStdString(targetValueStringRef);

    ELEMENT_SET_PROPERTY(name.c_str(), targetValueString.c_str(), args);

    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
  }

  ElementInstance::setProperty(name, value, exception);
}

void JSAnchorElement::AnchorElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getAnchorElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::array<JSStringRef, 2> &JSAnchorElement::AnchorElementInstance::getAnchorElementPropertyNames() {
  static std::array<JSStringRef, 2> propertyNames{
    JSStringCreateWithUTF8CString("href"),
    JSStringCreateWithUTF8CString("target"),
  };
  return propertyNames;
}
const std::unordered_map<std::string, JSAnchorElement::AnchorElementInstance::AnchorElementProperty> &
JSAnchorElement::AnchorElementInstance::getAnchorElementPropertyMap() {
  static const std::unordered_map<std::string, AnchorElementProperty> propertyMap{
    {"href", AnchorElementProperty::kHref}, {"target", AnchorElementProperty::kTarget}};
  return propertyMap;
}

JSAnchorElement::AnchorElementInstance::~AnchorElementInstance() {
  delete nativeAnchorElement;
  if (_target != nullptr) JSStringRelease(_target);
  if (_href != nullptr) JSStringRelease(_href);
}

} // namespace kraken::binding::jsc
