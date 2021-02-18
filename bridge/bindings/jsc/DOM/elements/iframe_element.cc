/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "iframe_element.h"
#include "foundation/ui_command_callback_queue.h"

namespace kraken::binding::jsc {

std::unordered_map<JSContext *, JSIframeElement *> JSIframeElement::instanceMap {};

JSIframeElement::~JSIframeElement() {
  instanceMap.erase(context);
}

JSIframeElement::JSIframeElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSIframeElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                 const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new IframeElementInstance(this);
  return instance->object;
}

JSIframeElement::IframeElementInstance::IframeElementInstance(JSIframeElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "iframe", false), nativeIframeElement(new NativeIframeElement(nativeElement)) {
  std::string tagName = "iframe";

  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);
  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(eventTargetId, UICommand::createElement, args_01, nativeIframeElement);
}

JSValueRef JSIframeElement::IframeElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getIFrameElementPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case IFrameElementProperty::width:
      return JSValueMakeNumber(_hostClass->ctx, _width);
    case IFrameElementProperty::height:
      return JSValueMakeNumber(_hostClass->ctx, _height);
    case IFrameElementProperty::contentWindow:
      // TODO: support contentWindow property.
      break;
    case IFrameElementProperty::postMessage:
      return m_postMessage.function();
    }
  }

  return ElementInstance::getProperty(name, exception);
}

bool JSIframeElement::IframeElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getIFrameElementPropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case IFrameElementProperty::width: {
      _width = JSValueToNumber(_hostClass->ctx, value, exception);

      std::string widthString = std::to_string(_width);
      NativeString args_01{};
      NativeString args_02{};

      buildUICommandArgs(name, widthString, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    case IFrameElementProperty::height: {
      _height = JSValueToNumber(_hostClass->ctx, value, exception);

      std::string heightString = std::to_string(_height);

      NativeString args_01{};
      NativeString args_02{};
      buildUICommandArgs(name, heightString, args_01, args_02);
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

void JSIframeElement::IframeElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getIFrameElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSIframeElement::IframeElementInstance::~IframeElementInstance() {
  ::foundation::UICommandCallbackQueue::instance(contextId)->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeIframeElement *>(ptr);
  }, nativeIframeElement);
}

JSValueRef JSIframeElement::IframeElementInstance::postMessage(JSContextRef ctx, JSObjectRef function,
                                                               JSObjectRef thisObject, size_t argumentCount,
                                                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to execute 'postMessage' on 'IframeElement: 1 arguments required.'", exception);
    return nullptr;
  }

  if (!JSValueIsString(ctx, arguments[0])) {
    throwJSError(ctx, "Failed to execute 'postMessage' on 'IframeElement: first arguments should be string'",
                    exception);
    return nullptr;
  }

  JSStringRef messageStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  NativeString message{};
  message.string = JSStringGetCharactersPtr(messageStringRef);
  message.length = JSStringGetLength(messageStringRef);

  auto instance = reinterpret_cast<JSIframeElement::IframeElementInstance *>(JSObjectGetPrivate(function));
  assert_m(instance->nativeIframeElement->postMessage != nullptr, "Failed to execute postMessage(): dart method is nullptr.");
  instance->nativeIframeElement->postMessage(instance->nativeIframeElement, &message);

  return nullptr;
}

} // namespace kraken::binding::jsc
