/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "animation_player_element.h"
#include "foundation/ui_command_callback_queue.h"

namespace kraken::binding::jsc {

std::unordered_map<JSContext *, JSAnimationPlayerElement *> JSAnimationPlayerElement::instanceMap{};

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
    throwJSError(ctx, "Failed to execute play() on AnimationPlayerElement: 1 arguments required but got 0.",
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
    static_cast<JSAnimationPlayerElement::AnimationPlayerElementInstance *>(JSObjectGetPrivate(thisObject));

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
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);
  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(eventTargetId, UICommand::createElement, args_01, nativeAnimationPlayerElement);
}

JSValueRef JSAnimationPlayerElement::AnimationPlayerElementInstance::getProperty(std::string &name,
                                                                                 JSValueRef *exception) {
  auto propertyMap = getAnimationPlayerPropertyMap();
  auto prototypePropertyMap = getAnimationPlayerPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);
  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSAnimationPlayerElement>()->prototypeObject, nameStringHolder.getString(), exception);
  };

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case AnimationPlayerProperty::src:
      return m_src.makeString();
    case AnimationPlayerProperty::type:
      return m_type.makeString();
    }
  }

  return ElementInstance::getProperty(name, exception);
}

bool JSAnimationPlayerElement::AnimationPlayerElementInstance::setProperty(std::string &name, JSValueRef value,
                                                                           JSValueRef *exception) {
  auto propertyMap = getAnimationPlayerPropertyMap();
  auto prototypePropertyMap = getAnimationPlayerPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSAnimationPlayerElement>()->prototypeObject, nameStringHolder.getString(), exception);
  };

  auto property = propertyMap[name];

  if (property == AnimationPlayerProperty::src) {
    JSStringRef src = JSValueToStringCopy(_hostClass->ctx, value, exception);
    context->handleException(*exception);
    m_src.setString(src);

    NativeString args_01{};
    NativeString args_02{};
    buildUICommandArgs(name, src, args_01, args_02);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
    return true;
  } else if (property == AnimationPlayerProperty::type) {
    JSStringRef type = JSValueToStringCopy(_hostClass->ctx, value, exception);
    m_type.setString(type);

    NativeString args_01{};
    NativeString args_02{};

    buildUICommandArgs(name, type, args_01, args_02);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
    return true;
  } else {
    return ElementInstance::setProperty(name, value, exception);
  }
}

void JSAnimationPlayerElement::AnimationPlayerElementInstance::getPropertyNames(
  JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getAnimationPlayerPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (auto &property : getAnimationPlayerPrototypePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSAnimationPlayerElement::AnimationPlayerElementInstance::~AnimationPlayerElementInstance() {
  ::foundation::UICommandCallbackQueue::instance(contextId)->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeAnimationPlayerElement *>(ptr);
  }, nativeAnimationPlayerElement);
}

} // namespace kraken::binding::jsc
