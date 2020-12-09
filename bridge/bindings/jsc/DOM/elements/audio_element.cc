/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "audio_element.h"
#include "foundation/ui_command_callback_queue.h"

namespace kraken::binding::jsc {

std::unordered_map<JSContext *, JSAudioElement *> JSAudioElement::instanceMap {};

JSAudioElement *JSAudioElement::instance(JSContext *context) {
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSAudioElement(context);
  }
  return instanceMap[context];
}

JSAudioElement::~JSAudioElement() {
  instanceMap.erase(context);
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
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);
  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
      ->registerCommand(eventTargetId, UICommand::createElement, args_01, nativeAudioElement);
}

JSAudioElement::AudioElementInstance::~AudioElementInstance() {
  ::foundation::UICommandCallbackQueue::instance(contextId)->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeAudioElement *>(ptr);
  }, nativeAudioElement);
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
