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
  elementInstance->nativeAnimationPlayerElement->play(elementInstance->nativeAnimationPlayerElement, &name, mix,
                                                      mixSeconds);

  return nullptr;
}

JSAnimationPlayerElement::AnimationPlayerElementInstance::AnimationPlayerElementInstance(
  JSAnimationPlayerElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "animation-player", false),
    nativeAnimationPlayerElement(new NativeAnimationPlayerElement(nativeElement)) {
  std::string tagName = "animation-player";
  auto args = buildUICommandArgs(tagName);
  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(eventTargetId, UI_COMMAND_CREATE_ELEMENT, args, 1, nativeAnimationPlayerElement);
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
  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];
    switch (property) {
    case AnimationPlayerProperty::kSrc:
      return JSValueMakeString(_hostClass->ctx, m_src);
    case AnimationPlayerProperty::kType:
      return JSValueMakeString(_hostClass->ctx, m_type);
    case AnimationPlayerProperty::kPlay: {
      return m_play.function();
    }
    }
  }

  return ElementInstance::getProperty(name, exception);
}

void JSAnimationPlayerElement::AnimationPlayerElementInstance::setProperty(std::string &name, JSValueRef value,
                                                                           JSValueRef *exception) {
  auto propertyMap = getAnimationPlayerElementPropertyMap();
  auto property = propertyMap[name];

  if (property == AnimationPlayerProperty::kSrc) {
    m_src = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(m_src);

    auto args = buildUICommandArgs(name, m_src);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UI_COMMAND_SET_PROPERTY, args, 2, nullptr);
  } else if (property == AnimationPlayerProperty::kType) {
    m_type = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(m_type);

    auto args = buildUICommandArgs(name, m_type);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UI_COMMAND_SET_PROPERTY, args, 2, nullptr);
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
  if (m_src != nullptr) JSStringRelease(m_src);
  if (m_type != nullptr) JSStringRelease(m_type);
}

} // namespace kraken::binding::jsc
