/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "animation_player_element.h"
#include "foundation/ui_command_callback_queue.h"

namespace kraken::binding::jsc {

std::unordered_map<JSContext *, JSAnimationPlayerElement *> JSAnimationPlayerElement::instanceMap{};

JSAnimationPlayerElement *JSAnimationPlayerElement::instance(JSContext *context) {
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSAnimationPlayerElement(context);
  }
  return instanceMap[context];
}

JSAnimationPlayerElement::~JSAnimationPlayerElement() {
  instanceMap.erase(context);
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

  if (argumentCount > 0) {
    JSStringRef nameStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
    name.string = JSStringGetCharactersPtr(nameStringRef);
    name.length = JSStringGetLength(nameStringRef);
  }

  if (argumentCount > 1) {
    mix = JSValueToNumber(ctx, arguments[1], exception);
  }

  if (argumentCount > 2) {
    mixSeconds = JSValueToNumber(ctx, arguments[2], exception);
  }

  auto elementInstance =
    static_cast<JSAnimationPlayerElement::AnimationPlayerElementInstance *>(JSObjectGetPrivate(function));

  getDartMethod()->flushUICommand();
  assert_m(elementInstance->nativeAnimationPlayerElement->play != nullptr,
           "Failed to call dart method: play() is nullptr");
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
    ->registerCommand(eventTargetId, UICommand::createElement, args, 1, nativeAnimationPlayerElement);
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
      return m_src.makeString();
    case AnimationPlayerProperty::kType:
      return m_type.makeString();
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
    JSStringRef src = JSValueToStringCopy(_hostClass->ctx, value, exception);
    m_src.setString(src);

    auto args = buildUICommandArgs(name, src);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommand::setProperty, args, 2, nullptr);
  } else if (property == AnimationPlayerProperty::kType) {
    JSStringRef type = JSValueToStringCopy(_hostClass->ctx, value, exception);
    m_type.setString(type);

    auto args = buildUICommandArgs(name, type);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommand::setProperty, args, 2, nullptr);
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
  ::foundation::UICommandCallbackQueue::instance(context->getContextId())->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeAnimationPlayerElement *>(ptr);
  }, nativeAnimationPlayerElement);
}

} // namespace kraken::binding::jsc
