/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "animation_player_element.h"

namespace kraken::binding::jsc {

JSAnimationPlayerElement *JSAnimationPlayerElement::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSAnimationPlayerElement *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSAnimationPlayerElement(context);
  }
  return instanceMap[context];
}

JSAnimationPlayerElement::JSAnimationPlayerElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSAnimationPlayerElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor,
                                                          size_t argumentCount, const JSValueRef *arguments,
                                                          JSValueRef *exception) {
  auto instance = new AnimationPlayerElementInstance(this);
  return instance->object;
}

JSValueRef JSAnimationPlayerElement::play(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                          size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  NativeString name{};
  double mix = 1.0;
  double mixSeconds = 0.2;

  if (argumentCount < 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute play() on AnimationPlayerElement: 1 arguments required but got 0.",
                    exception);
    return nullptr;
  }

  if (argumentCount < 2) {
    JSStringRef nameStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
    name.string = JSStringGetCharactersPtr(nameStringRef);
    name.length = JSStringGetLength(nameStringRef);
  }

  if (argumentCount < 3) {
    mix = JSValueToNumber(ctx, arguments[1], exception);
  }

  if (argumentCount < 4) {
    mixSeconds = JSValueToNumber(ctx, arguments[2], exception);
  }

  auto elementInstance =
    static_cast<JSAnimationPlayerElement::AnimationPlayerElementInstance *>(JSObjectGetPrivate(function));

  getDartMethod()->requestUpdateFrame();
  elementInstance->nativeAnimationPlayerElement->play(elementInstance->nativeAnimationPlayerElement, &name, mix, mixSeconds);

  return nullptr;
}

JSAnimationPlayerElement::AnimationPlayerElementInstance::AnimationPlayerElementInstance(
  JSAnimationPlayerElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "animation-player"), nativeAnimationPlayerElement(new NativeAnimationPlayerElement(nativeElement)) {
  JSStringRef canvasTagNameStringRef = JSStringCreateWithUTF8CString("animation-player");

  auto args = buildUICommandArgs(canvasTagNameStringRef);
  foundation::UICommandTaskMessageQueue::instance(_hostClass->context->getContextId())
      ->registerCommand(eventTargetId, UICommandType::createElement, args, 1, nativeAnimationPlayerElement);
}

std::vector<JSStringRef> &
JSAnimationPlayerElement::AnimationPlayerElementInstance::getAnimationPlayerElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("src"), JSStringCreateWithUTF8CString("type"), JSStringCreateWithUTF8CString("play")};
  return propertyNames;
}

const std::unordered_map<std::string, JSAnimationPlayerElement::AnimationPlayerElementInstance::AnimationPlayerProperty>
  &JSAnimationPlayerElement::AnimationPlayerElementInstance::getAnimationPlayerElementPropertyMap() {
  static std::unordered_map<std::string, AnimationPlayerProperty> propertyMap{{"src", AnimationPlayerProperty::kSrc},
                                                                              {"type", AnimationPlayerProperty::kType},
                                                                              {"play", AnimationPlayerProperty::kPlay}};
  return propertyMap;
}

JSValueRef JSAnimationPlayerElement::AnimationPlayerElementInstance::getProperty(std::string &name,
                                                                                 JSValueRef *exception) {
  auto propertyMap = getAnimationPlayerElementPropertyMap();
  auto property = propertyMap[name];

  if (property == AnimationPlayerProperty::kSrc) {
    return JSValueMakeString(_hostClass->ctx, _src);
  } else if (property == AnimationPlayerProperty::kType) {
    return JSValueMakeString(_hostClass->ctx, _type);
  } else if (property == AnimationPlayerProperty::kPlay) {
    if (_play == nullptr) {
      _play = propertyBindingFunction(_hostClass->context, this, "play", play);
      JSValueProtect(_hostClass->ctx, _play);
    }
    return _play;
  }

  return ElementInstance::getProperty(name, exception);
}

void JSAnimationPlayerElement::AnimationPlayerElementInstance::setProperty(std::string &name, JSValueRef value,
                                                                           JSValueRef *exception) {
  auto propertyMap = getAnimationPlayerElementPropertyMap();
  auto property = propertyMap[name];

  if (property == AnimationPlayerProperty::kSrc) {
    _src = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(_src);

    auto args = buildUICommandArgs(name, _src);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
  } else if (property == AnimationPlayerProperty::kType) {
    _type = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(_type);

    auto args = buildUICommandArgs(name, _type);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
  } else {
    ElementInstance::setProperty(name, value, exception);
  }
}

void JSAnimationPlayerElement::AnimationPlayerElementInstance::getPropertyNames(
  JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getAnimationPlayerElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSAnimationPlayerElement::AnimationPlayerElementInstance::~AnimationPlayerElementInstance() {
  delete nativeAnimationPlayerElement;
  if (_play != nullptr) JSValueUnprotect(_hostClass->ctx, _play);
  if (_src != nullptr) JSStringRelease(_src);
  if (_type != nullptr) JSStringRelease(_type);
}

} // namespace kraken::binding::jsc
