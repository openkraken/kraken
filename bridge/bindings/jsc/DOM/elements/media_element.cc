/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "media_element.h"
#include "foundation/ui_command_callback_queue.h"

namespace kraken::binding::jsc {

std::unordered_map<JSContext *, JSMediaElement *> JSMediaElement::instanceMap {};

JSMediaElement::~JSMediaElement() {
  instanceMap.erase(context);
}

JSMediaElement::JSMediaElement(JSContext *context) : JSElement(context) {}

JSMediaElement::MediaElementInstance::MediaElementInstance(JSMediaElement *jsMediaElement, const char *tagName)
  : ElementInstance(jsMediaElement, tagName, false), nativeMediaElement(new NativeMediaElement(nativeElement)) {}

JSMediaElement::MediaElementInstance::~MediaElementInstance() {
  if (_src != nullptr) JSStringRelease(_src);

  ::foundation::UICommandCallbackQueue::instance()->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeMediaElement *>(ptr);
  }, nativeMediaElement);
}

JSValueRef JSMediaElement::MediaElementInstance::play(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                      size_t argumentCount, const JSValueRef *arguments,
                                                      JSValueRef *exception) {
  auto elementInstance = reinterpret_cast<JSMediaElement::MediaElementInstance *>(JSObjectGetPrivate(function));
  getDartMethod()->flushUICommand();
  assert_m(elementInstance->nativeMediaElement->play != nullptr, "Failed to execute play(): dart method is nullptr.");
  elementInstance->nativeMediaElement->play(elementInstance->nativeMediaElement);
  return nullptr;
}

JSValueRef JSMediaElement::MediaElementInstance::pause(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                       size_t argumentCount, const JSValueRef *arguments,
                                                       JSValueRef *exception) {
  auto elementInstance = reinterpret_cast<JSMediaElement::MediaElementInstance *>(JSObjectGetPrivate(function));
  getDartMethod()->flushUICommand();
  assert_m(elementInstance->nativeMediaElement->pause != nullptr, "Failed to execute pause(): dart method is nullptr.");
  elementInstance->nativeMediaElement->pause(elementInstance->nativeMediaElement);
  return nullptr;
}

JSValueRef JSMediaElement::MediaElementInstance::fastSeek(JSContextRef ctx, JSObjectRef function,
                                                          JSObjectRef thisObject, size_t argumentCount,
                                                          const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    throwJSError(ctx, "Failed to execute fastSeek() on MediaElement: 1 arguments is required but got 0.", exception);
    return nullptr;
  }

  if (!JSValueIsNumber(ctx, arguments[0])) {
    throwJSError(ctx, "Failed to execute fastSeek() on MediaElement: duration must be an number.", exception);
    return nullptr;
  }

  double duration = JSValueToNumber(ctx, arguments[0], exception);

  auto elementInstance = reinterpret_cast<JSMediaElement::MediaElementInstance *>(JSObjectGetPrivate(function));

  getDartMethod()->flushUICommand();
  assert_m(elementInstance->nativeMediaElement->fastSeek != nullptr, "Failed to execute fastSeek(): dart method is nullptr.");
  elementInstance->nativeMediaElement->fastSeek(elementInstance->nativeMediaElement, duration);

  return nullptr;
}

JSValueRef JSMediaElement::MediaElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getMediaElementPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch(property) {

    case MediaElementProperty::currentSrc:
    case MediaElementProperty::src:
      return JSValueMakeString(_hostClass->ctx, _src);
    case MediaElementProperty::autoPlay:
      return JSValueMakeBoolean(_hostClass->ctx, _autoPlay);
    case MediaElementProperty::loop:
      return JSValueMakeBoolean(_hostClass->ctx, _loop);
    case MediaElementProperty::play:
      return m_play.function();
    case MediaElementProperty::pause:
      return m_pause.function();
    case MediaElementProperty::fastSeek:
      return m_fastSeek.function();
    }
  }

  return ElementInstance::getProperty(name, exception);
}

void JSMediaElement::MediaElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getMediaElementPropertyMap();
  auto property = propertyMap[name];

  if (property == MediaElementProperty::src) {
    _src = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(_src);

    NativeString args_01{};
    NativeString args_02{};

    buildUICommandArgs(name, _src, args_01, args_02);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId,UICommand::setProperty, args_01, args_02, nullptr);
  }

  ElementInstance::setProperty(name, value, exception);
}

void JSMediaElement::MediaElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getMediaElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
