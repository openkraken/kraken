/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "video_element.h"

namespace kraken::binding::jsc {

JSVideoElement *JSVideoElement::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSVideoElement *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSVideoElement(context);
  }
  return instanceMap[context];
}

JSVideoElement::JSVideoElement(JSContext *context) : JSMediaElement(context) {}

JSObjectRef JSVideoElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new VideoElementInstance(this);
  return instance->object;
}

JSVideoElement::VideoElementInstance::VideoElementInstance(JSVideoElement *JSVideoElement)
  : MediaElementInstance(JSVideoElement, "video"), nativeVideoElement(new NativeVideoElement(nativeMediaElement)) {
  JSStringRef tagNameStringRef = JSStringCreateWithUTF8CString("video");
  auto args = buildUICommandArgs(tagNameStringRef);

  foundation::UICommandTaskMessageQueue::instance(_hostClass->context->getContextId())
      ->registerCommand(eventTargetId, UICommandType::createElement, args, 1, nativeVideoElement);
}

JSVideoElement::VideoElementInstance::~VideoElementInstance() {
  delete nativeVideoElement;
}

std::vector<JSStringRef> &JSVideoElement::VideoElementInstance::getAudioElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{};
  return propertyNames;
}

const std::unordered_map<std::string, JSVideoElement::VideoElementInstance::AudioElementProperty> &
JSVideoElement::VideoElementInstance::getAudioElementPropertyMap() {
  static std::unordered_map<std::string, AudioElementProperty> propertyMap{};
  return propertyMap;
}

} // namespace kraken::binding::jsc
