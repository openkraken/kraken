/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */


#include "eventTarget.h"
#include "dart_methods.h"

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

JSEventTarget::JSEventTarget(JSContext &context): context(context) {
  nativeEventTarget = getDartMethod()->createEventTarget(context.getContextId());
}

Value JSEventTarget::get(JSContext &, const PropNameID &name) {
  return Value::undefined();
}

void JSEventTarget::set(JSContext &, const PropNameID &name, const Value &value) {}

std::vector<PropNameID> JSEventTarget::getPropertyNames(JSContext &context) {
  std::vector<PropNameID> propertyNames;
  return propertyNames;
}

}
}
