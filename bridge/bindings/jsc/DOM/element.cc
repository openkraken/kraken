/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "dart_methods.h"
#include "eventTarget.h"
#include "foundation/logging.h"
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

JSElement::ElementInstance::ElementInstance(JSElement *element, size_t argumentsCount, const JSValueRef *arguments,
                                            JSValueRef *exception)
  : EventTargetInstance(element, argumentsCount, arguments, exception) {
  const JSValueRef tagNameValue = arguments[0];
  JSStringRef tagNameStrRef = JSValueToStringCopy(element->ctx, tagNameValue, exception);
  NativeString tagName{};
  tagName.string = JSStringGetCharactersPtr(tagNameStrRef);
  tagName.length = JSStringGetLength(tagNameStrRef);

  const int32_t argsLength = 1;
  auto **args = new NativeString *[argsLength];
  args[0] = tagName.clone();

  KRAKEN_LOG(VERBOSE) << "register ui command " << eventTargetId << " createElement";

  UICommandTaskMessageQueue::instance(element->context->getContextId())
      ->registerCommand(eventTargetId, UICommandType::createElement, args, argsLength);
}

void JSElement::ElementInstance::initialized() {
  Instance::initialized();
}

} // namespace kraken::binding::jsc
