/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "dart_methods.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {
using namespace foundation;

namespace {
  JSElement *_instance {nullptr};
}

void bindElement(std::unique_ptr<JSContext> &context) {
  auto element = JSElement::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Element", element->classObject);
}

JSElement::JSElement(JSContext *context) : JSNode(context, "Element", NodeType::ELEMENT_NODE) {}

void JSElement::constructor(JSContextRef ctx, JSObjectRef constructor, JSObjectRef newInstance, size_t argumentCount,
                            const JSValueRef *arguments, JSValueRef *exception) {

  const JSValueRef tagNameValue = arguments[0];
  JSStringRef tagNameStrRef = JSValueToStringCopy(ctx, tagNameValue, exception);
  NativeString tagName{};
  tagName.string = JSStringGetCharactersPtr(tagNameStrRef);
  tagName.length = JSStringGetLength(tagNameStrRef);

  const int32_t argsLength = 1;
  auto **args = new NativeString *[argsLength];
  args[0] = tagName.clone();
  UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(getEventTargetId(), UICommandType::createElement, args, argsLength);
}

JSElement *JSElement::instance(JSContext *context) {
  if (_instance == nullptr) {
    _instance = new JSElement(context);
  }
  return _instance;
}

} // namespace kraken::binding::jsc
