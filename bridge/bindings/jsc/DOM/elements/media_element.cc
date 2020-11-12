/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "media_element.h"

namespace kraken::binding::jsc {

JSMediaElement *JSMediaElement::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSMediaElement *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSMediaElement(context);
  }
  return instanceMap[context];
}

JSMediaElement::JSMediaElement(JSContext *context) : JSElement(context) {}

JSMediaElement::MediaElementInstance::MediaElementInstance(JSMediaElement *jsMediaElement, const char *tagName)
  : ElementInstance(jsMediaElement, tagName), nativeMediaElement(new NativeMediaElement(nativeElement)) {}

JSMediaElement::MediaElementInstance::~MediaElementInstance() {
  delete nativeMediaElement;
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
  elementInstance->nativeMediaElement->play(elementInstance->_hostClass->contextId, elementInstance->eventTargetId);
  return nullptr;
}

JSValueRef JSMediaElement::MediaElementInstance::pause(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                       size_t argumentCount, const JSValueRef *arguments,
                                                       JSValueRef *exception) {
  auto elementInstance = reinterpret_cast<JSMediaElement::MediaElementInstance *>(JSObjectGetPrivate(function));
  elementInstance->nativeMediaElement->pause(elementInstance->_hostClass->contextId, elementInstance->eventTargetId);
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
  elementInstance->nativeMediaElement->fastSeek(elementInstance->_hostClass->contextId, elementInstance->eventTargetId,
                                                duration);

  return nullptr;
}

JSValueRef JSMediaElement::MediaElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getMediaElementPropertyMap();
  auto property = propertyMap[name];

  if (property == MediaElementProperty::kSrc || property == MediaElementProperty::kCurrentSrc) {
    return JSValueMakeString(_hostClass->ctx, _src);
  } else if (property == MediaElementProperty::kLoop) {
    return JSValueMakeBoolean(_hostClass->ctx, _loop);
  } else if (property == MediaElementProperty::kAutoPlay) {
    return JSValueMakeBoolean(_hostClass->ctx, _autoPlay);
  } else if (property == MediaElementProperty::kPlay) {
    if (_play == nullptr) {
      _play = propertyBindingFunction(_hostClass->context, this, "play", play);
    }
    return _play;
  } else if (property == MediaElementProperty::kPause) {
    if (_pause == nullptr) {
      _pause = propertyBindingFunction(_hostClass->context, this, "pause", pause);
    }
    return _pause;
  } else if (property == MediaElementProperty::kFastSeek) {
    if (_fastSeek == nullptr) {
      _fastSeek = propertyBindingFunction(_hostClass->context, this, "fastSeek", fastSeek);
    }
    return _fastSeek;
  }

  return ElementInstance::getProperty(name, exception);
}

void JSMediaElement::MediaElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getMediaElementPropertyMap();
  auto property = propertyMap[name];

  if (property == MediaElementProperty::kSrc) {
    NativeString **args = new NativeString *[2];

    JSStringRef srcValueStringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(srcValueStringRef);
    _src = srcValueStringRef;

    std::string valueString = JSStringToStdString(srcValueStringRef);

    ELEMENT_SET_PROPERTY(name.c_str(), valueString.c_str(), args);

    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
  }

  NodeInstance::setProperty(name, value, exception);
}

void JSMediaElement::MediaElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getMediaElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
