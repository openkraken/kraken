/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "image_element.h"

namespace kraken::binding::jsc {

JSImageElement *JSImageElement::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSImageElement *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSImageElement(context);
  }
  return instanceMap[context];
}

JSImageElement::JSImageElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSImageElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new ImageElementInstance(this);
  return instance->object;
}

JSImageElement::ImageElementInstance::ImageElementInstance(JSImageElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "image"), nativeImageElement(new NativeImageElement(nativeElement)) {
  JSStringRef canvasTagNameStringRef = JSStringCreateWithUTF8CString("image");
  NativeString tagName{};
  tagName.string = JSStringGetCharactersPtr(canvasTagNameStringRef);
  tagName.length = JSStringGetLength(canvasTagNameStringRef);

  const int32_t argsLength = 1;
  auto **args = new NativeString *[argsLength];
  args[0] = tagName.clone();

  foundation::UICommandTaskMessageQueue::instance(_hostClass->context->getContextId())
    ->registerCommand(eventTargetId, UICommandType::createElement, args, argsLength, nativeImageElement);
}

std::vector<JSStringRef> &JSImageElement::ImageElementInstance::getImageElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{};
  return propertyNames;
}

const std::unordered_map<std::string, JSImageElement::ImageElementInstance::ImageProperty> &
JSImageElement::ImageElementInstance::getImageElementPropertyMap() {
  static std::unordered_map<std::string, ImageProperty> propertyMap{{"width", ImageProperty::kWidth},
                                                                    {"height", ImageProperty::kHeight}};
  return propertyMap;
}

JSValueRef JSImageElement::ImageElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getImageElementPropertyMap();
  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];
    switch (property) {
    case ImageProperty::kWidth:
      return JSValueMakeNumber(_hostClass->ctx, _width);
    case ImageProperty::kHeight:
      return JSValueMakeNumber(_hostClass->ctx, _height);
    }
  }

  return ElementInstance::getProperty(name, exception);
}

void JSImageElement::ImageElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getImageElementPropertyMap();

  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];
    switch (property) {
    case ImageProperty::kWidth: {
      _width = JSValueToNumber(_hostClass->ctx, value, exception);

      NativeString **args = new NativeString *[2];

      NativeString propertyKey{};
      STD_STRING_TO_NATIVE_STRING("width", propertyKey);

      NativeString propertyValue{};
      STD_STRING_TO_NATIVE_STRING(std::to_string(_width).c_str(), propertyValue);

      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
      break;
    }
    case ImageProperty::kHeight: {
      _height = JSValueToNumber(_hostClass->ctx, value, exception);

      NativeString **args = new NativeString *[2];

      NativeString propertyKey{};
      STD_STRING_TO_NATIVE_STRING("height", propertyKey);

      NativeString propertyValue{};
      STD_STRING_TO_NATIVE_STRING(std::to_string(_height).c_str(), propertyValue);

      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
      break;
    }
    default:
      break;
    }
  } else {
    NodeInstance::setProperty(name, value, exception);
  }
}

void JSImageElement::ImageElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getImageElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSImageElement::ImageElementInstance::~ImageElementInstance() {
  delete nativeImageElement;
}

} // namespace kraken::binding::jsc
