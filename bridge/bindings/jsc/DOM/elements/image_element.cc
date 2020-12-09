/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "image_element.h"
#include "foundation/ui_command_callback_queue.h"

namespace kraken::binding::jsc {

void bindImageElement(std::unique_ptr<JSContext> &context) {
  auto ImageElement = JSImageElement::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Image", ImageElement->classObject);
}

std::unordered_map<JSContext *, JSImageElement *> JSImageElement::instanceMap {};

JSImageElement *JSImageElement::instance(JSContext *context) {
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSImageElement(context);
  }
  return instanceMap[context];
}
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

std::vector<JSStringRef> &JSImageElement::ImageElementInstance::getImageElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("width"),
    JSStringCreateWithUTF8CString("height"),
    JSStringCreateWithUTF8CString("src"),
    JSStringCreateWithUTF8CString("loading"),
  };
  return propertyNames;
}

const std::unordered_map<std::string, JSImageElement::ImageElementInstance::ImageProperty> &
JSImageElement::ImageElementInstance::getImageElementPropertyMap() {
  static std::unordered_map<std::string, ImageProperty> propertyMap{{"width", ImageProperty::kWidth},
                                                                    {"height", ImageProperty::kHeight},
                                                                    {"src", ImageProperty::kSrc},
                                                                    {"loading", ImageProperty::kLoading}};
  return propertyMap;
}

JSValueRef JSImageElement::ImageElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getImageElementPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case ImageProperty::kWidth:
      return JSValueMakeNumber(_hostClass->ctx, nativeImageElement->getImageWidth(nativeImageElement));
    case ImageProperty::kHeight:
      return JSValueMakeNumber(_hostClass->ctx, nativeImageElement->getImageHeight(nativeImageElement));
    case ImageProperty::kSrc: {
      return m_src.makeString();
    }
    case ImageProperty::kLoading: {
      return m_loading.makeString();
    }
    }
  }

  return ElementInstance::getProperty(name, exception);
}

void JSImageElement::ImageElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getImageElementPropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case ImageProperty::kWidth: {
      double width = JSValueToNumber(_hostClass->ctx, value, exception);

      std::string widthString = std::to_string(width) + "px";
      NativeString args_01{};
      NativeString args_02{};

      buildUICommandArgs(name, widthString, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    case ImageProperty::kHeight: {
      double height = JSValueToNumber(_hostClass->ctx, value, exception);

      std::string heightString = std::to_string(height) + "px";

      NativeString args_01{};
      NativeString args_02{};

      buildUICommandArgs(name, heightString, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    case ImageProperty::kSrc: {
      JSStringRef src = JSValueToStringCopy(_hostClass->ctx, value, exception);
      m_src.setString(src);

      NativeString args_01{};
      NativeString args_02{};
      buildUICommandArgs(name, src, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    case ImageProperty::kLoading: {
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
  } else {
    ElementInstance::setProperty(name, value, exception);
  }
}

void JSImageElement::ImageElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getImageElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSImageElement::ImageElementInstance::~ImageElementInstance() {
  ::foundation::UICommandCallbackQueue::instance(contextId)->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeImageElement *>(ptr);
  }, nativeImageElement);
}

} // namespace kraken::binding::jsc
