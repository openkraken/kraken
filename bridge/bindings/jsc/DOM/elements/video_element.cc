/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "video_element.h"

namespace kraken::binding::jsc {

std::unordered_map<JSContext *, JSVideoElement *> &JSVideoElement::getInstanceMap() {
  static std::unordered_map<JSContext *, JSVideoElement *> instanceMap;
  return instanceMap;
}

JSVideoElement *JSVideoElement::instance(JSContext *context) {
  auto instanceMap = getInstanceMap();
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSVideoElement(context);
  }
  return instanceMap[context];
}

JSVideoElement::~JSVideoElement() {
  auto instanceMap = getInstanceMap();
  instanceMap.erase(context);
}

JSVideoElement::JSVideoElement(JSContext *context) : JSMediaElement(context) {}

JSObjectRef JSVideoElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new VideoElementInstance(this);
  return instance->object;
}

JSVideoElement::VideoElementInstance::VideoElementInstance(JSVideoElement *JSVideoElement)
  : MediaElementInstance(JSVideoElement, "video"), nativeVideoElement(new NativeVideoElement(nativeMediaElement)) {
  std::string tagName = "video";
  auto args = buildUICommandArgs(tagName);

  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(eventTargetId, UICommand::createElement, args, 1, nativeVideoElement);
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
