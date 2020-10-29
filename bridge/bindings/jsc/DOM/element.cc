/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "dart_methods.h"
#include "eventTarget.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {
using namespace foundation;

namespace {
JSElement *_instance{nullptr};
}

void bindElement(std::unique_ptr<JSContext> &context) {
  auto element = JSElement::instance(context.get());
  JSValueProtect(context->context(), element->classObject);
  JSC_GLOBAL_SET_PROPERTY(context, "Element", element->classObject);
}

JSElement::JSElement(JSContext *context) : JSNode(context, "Element", NodeType::ELEMENT_NODE) {}

JSElement *JSElement::instance(JSContext *context) {
  if (_instance == nullptr) {
    _instance = new JSElement(context);
  }
  return _instance;
}

JSObjectRef JSElement::constructInstance(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                         const JSValueRef *arguments, JSValueRef *exception) {
  JSValueRef tagNameValue = arguments[0];
  auto instance = new ElementInstance(this, tagNameValue, exception);
  return instance->object;
}

JSElement::ElementInstance::ElementInstance(JSElement *element, JSValueRef tagNameValue, JSValueRef *exception)
  : EventTargetInstance(element) {
  JSStringRef tagNameStrRef = JSValueToStringCopy(element->ctx, tagNameValue, exception);
  NativeString tagName{};
  tagName.string = JSStringGetCharactersPtr(tagNameStrRef);
  tagName.length = JSStringGetLength(tagNameStrRef);

  const int32_t argsLength = 1;
  auto **args = new NativeString *[argsLength];
  args[0] = tagName.clone();

  UICommandTaskMessageQueue::instance(element->context->getContextId())
      ->registerCommand(eventTargetId, UICommandType::createElement, args, argsLength);

}

void JSElement::ElementInstance::initialized() {
  Instance::initialized();
}

} // namespace kraken::binding::jsc
