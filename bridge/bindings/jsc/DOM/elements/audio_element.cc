/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "audio_element.h"

namespace kraken::binding::jsc {

JSAudioElement *JSAudioElement::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSAudioElement *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSAudioElement(context);
  }
  return instanceMap[context];
}

JSAudioElement::JSAudioElement(JSContext *context) : JSMediaElement(context) {}

JSObjectRef JSAudioElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new AudioElementInstance(this);
  return instance->object;
}

JSAudioElement::AudioElementInstance::AudioElementInstance(JSAudioElement *jsAudioElement)
  : MediaElementInstance(jsAudioElement, "audio"), nativeAudioElement(new NativeAudioElement(nativeMediaElement)) {
  std::string tagName = "audio";
  auto args = buildUICommandArgs(tagName);
  foundation::UICommandTaskMessageQueue::instance(_hostClass->context->getContextId())
      ->registerCommand(eventTargetId, UICommandType::createElement, args, 1, nativeAudioElement);
}

JSAudioElement::AudioElementInstance::~AudioElementInstance() {
  delete nativeAudioElement;
}

std::vector<JSStringRef> &JSAudioElement::AudioElementInstance::getAudioElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{};
  return propertyNames;
}

const std::unordered_map<std::string, JSAudioElement::AudioElementInstance::AudioElementProperty> &
JSAudioElement::AudioElementInstance::getAudioElementPropertyMap() {
  static std::unordered_map<std::string, AudioElementProperty> propertyMap {};
  return propertyMap;
}

} // namespace kraken::binding::jsc
