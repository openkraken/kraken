/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "media_element.h"
#include "foundation/ui_command_callback_queue.h"

namespace kraken::binding::jsc {

std::unordered_map<JSContext *, JSMediaElement *> JSMediaElement::instanceMap {};

JSMediaElement *JSMediaElement::instance(JSContext *context) {
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSMediaElement(context);
  }
  return instanceMap[context];
}
JSMediaElement::~JSMediaElement() {
  instanceMap.erase(context);
}

JSMediaElement::JSMediaElement(JSContext *context) : JSElement(context) {}

JSMediaElement::MediaElementInstance::MediaElementInstance(JSMediaElement *jsMediaElement, const char *tagName)
  : ElementInstance(jsMediaElement, tagName, false), nativeMediaElement(new NativeMediaElement(nativeElement)) {}

JSMediaElement::MediaElementInstance::~MediaElementInstance() {
  if (_src != nullptr) JSStringRelease(_src);

  ::foundation::UICommandCallbackQueue::instance(context->getContextId())->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeMediaElement *>(ptr);
  }, nativeMediaElement);
}

std::vector<JSStringRef> &JSMediaElement::MediaElementInstance::getMediaElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("src"),        JSStringCreateWithUTF8CString("autoplay"),
    JSStringCreateWithUTF8CString("loop"),       JSStringCreateWithUTF8CString("play"),
    JSStringCreateWithUTF8CString("pause"),      JSStringCreateWithUTF8CString("fastSeek"),
    JSStringCreateWithUTF8CString("currentSrc"),
  };
  return propertyNames;
}

const std::unordered_map<std::string, JSMediaElement::MediaElementInstance::MediaElementProperty> &
JSMediaElement::MediaElementInstance::getMediaElementPropertyMap() {
  static std::unordered_map<std::string, MediaElementProperty> propertyMap{
    {"src", MediaElementProperty::kSrc},
    {"autoplay", MediaElementProperty::kAutoPlay},
    {"loop", MediaElementProperty::kLoop},
    {"play", MediaElementProperty::kPlay},
    {"pause", MediaElementProperty::kPause},
    {"fastSeek", MediaElementProperty::kFastSeek},
    {"currentSrc", MediaElementProperty::kCurrentSrc}};
  return propertyMap;
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
    JSC_THROW_ERROR(ctx, "Failed to execute fastSeek() on MediaElement: 1 arguments is required but got 0.", exception);
    return nullptr;
  }

  if (!JSValueIsNumber(ctx, arguments[0])) {
    JSC_THROW_ERROR(ctx, "Failed to execute fastSeek() on MediaElement: duration must be an number.", exception);
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
  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];
    switch(property) {

    case MediaElementProperty::kCurrentSrc:
    case MediaElementProperty::kSrc:
      return JSValueMakeString(_hostClass->ctx, _src);
    case MediaElementProperty::kAutoPlay:
      return JSValueMakeBoolean(_hostClass->ctx, _autoPlay);
    case MediaElementProperty::kLoop:
      return JSValueMakeBoolean(_hostClass->ctx, _loop);
    case MediaElementProperty::kPlay:
      return m_play.function();
    case MediaElementProperty::kPause:
      return m_pause.function();
    case MediaElementProperty::kFastSeek:
      return m_fastSeek.function();
    }
  }

  return ElementInstance::getProperty(name, exception);
}

void JSMediaElement::MediaElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getMediaElementPropertyMap();
  auto property = propertyMap[name];

  if (property == MediaElementProperty::kSrc) {
    _src = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(_src);

    auto args = buildUICommandArgs(name, JSStringRetain(_src));
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId,UICommand::setProperty, args, 2, nullptr);
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
