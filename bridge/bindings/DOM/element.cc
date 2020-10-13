/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "dart_methods.h"

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

JSElement::JSElement(JSContext &context, NativeString *tagName) : JSNode(context, NodeType::ELEMENT_NODE) {
  if (getDartMethod()->createElement == nullptr) {
    throw JSError(context, "Failed to createElement: dart method (createElement) is not registered.");
  }
  getDartMethod()->createElement(context.getContextId(), getEventTarget(), tagName);
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
