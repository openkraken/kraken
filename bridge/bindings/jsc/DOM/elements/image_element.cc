/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "image_element.h"

namespace kraken::binding::jsc {

void bindImageElement(std::unique_ptr<JSContext> &context) {
  auto ImageElement = JSImageElement::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Image", ImageElement->classObject);
  JSC_GLOBAL_SET_PROPERTY(context, "HTMLImageElement", ImageElement->classObject);
}

std::unordered_map<JSContext *, JSImageElement *> JSImageElement::instanceMap {};

JSImageElement::~JSImageElement() {
  instanceMap.erase(context);
}

JSImageElement::JSImageElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSImageElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new ImageElementInstance(this);
  return instance->object;
}

JSImageElement::ImageElementInstance::ImageElementInstance(JSImageElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "img", false), nativeImageElement(new NativeImageElement(nativeElement)) {
  std::string tagName = "img";
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);

  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(eventTargetId, UICommand::createElement, args_01, nativeImageElement);
}

JSValueRef JSImageElement::ImageElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getImageElementPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case ImageElementProperty::width: {
      getDartMethod()->flushUICommand();
      return JSValueMakeNumber(_hostClass->ctx, nativeImageElement->getImageWidth(nativeImageElement));
    }
    case ImageElementProperty::height: {
      getDartMethod()->flushUICommand();
      return JSValueMakeNumber(_hostClass->ctx, nativeImageElement->getImageHeight(nativeImageElement));
    }
    case ImageElementProperty::naturalWidth: {
      getDartMethod()->flushUICommand();
      return JSValueMakeNumber(_hostClass->ctx, nativeImageElement->getImageNaturalWidth(nativeImageElement));
    }
    case ImageElementProperty::naturalHeight: {
      getDartMethod()->flushUICommand();
      return JSValueMakeNumber(_hostClass->ctx, nativeImageElement->getImageNaturalHeight(nativeImageElement));
    }
    case ImageElementProperty::src: {
      return m_src.makeString();
    }
    case ImageElementProperty::loading: {
      return m_loading.makeString();
    }
    }
  }

  return ElementInstance::getProperty(name, exception);
}

bool JSImageElement::ImageElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getImageElementPropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case ImageElementProperty::width:
    case ImageElementProperty::height: {
      JSStringRef stringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);
      std::string string = JSStringToStdString(stringRef);
      NativeString args_01{};
      NativeString args_02{};
      buildUICommandArgs(name, string, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    case ImageElementProperty::src: {
      JSStringRef src = JSValueToStringCopy(_hostClass->ctx, value, exception);
      m_src.setString(src);

      NativeString args_01{};
      NativeString args_02{};
      buildUICommandArgs(name, src, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    case ImageElementProperty::loading: {
      JSStringRef loading = JSValueToStringCopy(_hostClass->ctx, value, exception);
      m_loading.setString(loading);

      NativeString args_01{};
      NativeString args_02{};
      buildUICommandArgs(name, loading, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    default:
      break;
    }
    return true;
  } else {
    return ElementInstance::setProperty(name, value, exception);
  }
}

void JSImageElement::ImageElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getImageElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSImageElement::ImageElementInstance::~ImageElementInstance() {
  ::foundation::UICommandCallbackQueue::instance()->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeImageElement *>(ptr);
  }, nativeImageElement);
}

} // namespace kraken::binding::jsc
