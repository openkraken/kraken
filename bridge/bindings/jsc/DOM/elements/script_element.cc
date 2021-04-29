/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_element.h"

namespace kraken::binding::jsc {

JSScriptElement::JSScriptElement(JSContext *context) : JSElement(context) {}

std::unordered_map<JSContext *, JSScriptElement *> JSScriptElement::instanceMap {};

JSScriptElement::~JSScriptElement() {
  instanceMap.erase(context);
}

JSObjectRef JSScriptElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                 const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new ScriptElementInstance(this);
  return instance->object;
}

JSScriptElement::ScriptElementInstance::ScriptElementInstance(JSScriptElement *jsElement)
  : ElementInstance(jsElement, "script", false) {
  std::string tagName = "script";
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);

  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
      ->registerCommand(eventTargetId, UICommand::createElement, args_01, nativeElement);
}

JSValueRef JSScriptElement::ScriptElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getScriptElementPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case ScriptElementProperty::src:
      return JSValueMakeString(_hostClass->ctx, _src);
    }
  }

  return ElementInstance::getProperty(name, exception);
}

bool JSScriptElement::ScriptElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getScriptElementPropertyMap();

  if (propertyMap.count(name) == 0) return ElementInstance::setProperty(name, value, exception);

  auto property = propertyMap[name];
  if (property == ScriptElementProperty::src) {
    _src = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(_src);

    std::string srcString = JSStringToStdString(_src);

    NativeString args_01{};
    NativeString args_02{};
    buildUICommandArgs(name, srcString, args_01, args_02);
    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
    return true;
  }

  return true;
}

void JSScriptElement::ScriptElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getScriptElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSScriptElement::ScriptElementInstance::~ScriptElementInstance() {
  if (_src != nullptr) JSStringRelease(_src);
}

} // namespace kraken::binding::jsc
