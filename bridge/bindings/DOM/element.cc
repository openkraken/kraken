/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "dart_methods.h"
#include "foundation/ui_command_queue.h"
#include <iostream>

namespace kraken {
namespace binding {
using namespace alibaba::jsa;
using namespace foundation;

JSElement::JSElement(JSContext &context, NativeString *tagName) : JSNode(context, NodeType::ELEMENT_NODE) {
  const int32_t argsLength = 1;
  NativeString **args = new NativeString* [argsLength];
  args[0] = tagName;
  UICommandTaskMessageQueue::instance(context.getContextId())
    ->registerCommand(getEventTargetId(), KARKEN_CREATE_ELEMENT, args, argsLength);
}

Value JSElement::get(JSContext &context, const PropNameID &name) {
  return Value::undefined();
}

void JSElement::set(JSContext &, const PropNameID &name, const Value &value) {}

std::vector<PropNameID> JSElement::getPropertyNames(JSContext &context) {
  std::vector<PropNameID> propertyNames;
  return propertyNames;
}

} // namespace binding
} // namespace kraken
