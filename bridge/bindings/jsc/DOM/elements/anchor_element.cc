/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "anchor_element.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

JSAnchorElement::JSAnchorElement(JSContext *context) : JSElement(context) {}

JSAnchorElement *JSAnchorElement::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSAnchorElement*> instanceMap {};
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
  : ElementInstance(jsAnchorElement, "a") {}

JSValueRef JSAnchorElement::AnchorElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  if (name == "href") {
    return JSValueMakeString(_hostClass->ctx, _href);
  } else if (name == "target") {
    return JSValueMakeString(_hostClass->ctx, _target);
  }

  return ElementInstance::getProperty(name, exception);
}

void JSAnchorElement::AnchorElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  if (name == "href") {
    NativeString hrefProperty{};
    STD_STRING_TO_NATIVE_STRING(name.c_str(), hrefProperty);

    NativeString hrefValue{};
    JSStringRef hrefValueStringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);
    std::string hrefValueString = JSStringToStdString(hrefValueStringRef);
    STD_STRING_TO_NATIVE_STRING(hrefValueString.c_str(), hrefValue);

    NativeString **args = new NativeString *[2];
    args[0] = hrefProperty.clone();
    args[1] = hrefValue.clone();

    JSStringRetain(hrefValueStringRef);
    _href = hrefValueStringRef;

    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
  } else if (name == "target") {
    NativeString targetProperty{};
    STD_STRING_TO_NATIVE_STRING(name.c_str(), targetProperty);

    NativeString targetValue{};
    JSStringRef targetValueStringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);
    std::string targetValueString = JSStringToStdString(targetValueStringRef);
    STD_STRING_TO_NATIVE_STRING(targetValueString.c_str(), targetValue);

    JSStringRetain(targetValueStringRef);
    _target = targetValueStringRef;

    NativeString **args = new NativeString *[2];
    args[0] = targetProperty.clone();
    args[1] = targetValue.clone();

    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
  }

  ElementInstance::setProperty(name, value, exception);
}

void JSAnchorElement::AnchorElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getAnchorElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::array<JSStringRef, 2> & JSAnchorElement::AnchorElementInstance::getAnchorElementPropertyNames() {
  static std::array<JSStringRef, 2> propertyNames {
    JSStringCreateWithUTF8CString("href"),
    JSStringCreateWithUTF8CString("target"),
  };
  return propertyNames;
}

} // namespace kraken::binding::jsc
