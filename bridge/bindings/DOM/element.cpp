//
// Created by andycall on 2020/9/23.
//

#include "element.h"
#include "dart_methods.h"

namespace kraken {
namespace binding {

JSElement::JSElement(JSContext &context, NativeString *tagName) {
  if (getDartMethod()->createElement == nullptr) {
    throw JSError(context, "Failed to createElement: dart method (createElement) is not registered.");
  }
  _dartElement = getDartMethod()->createElement(tagName);
}

Value JSElement::get(JSContext &, const PropNameID &name) {
  return Value::undefined();
}

void JSElement::set(JSContext &, const PropNameID &name, const Value &value) {}

std::vector<PropNameID> JSElement::getPropertyNames(JSContext &context) {
  std::vector<PropNameID> propertyNames;
  return propertyNames;
}

Value JSElementStyle::get(JSContext &, const PropNameID &name) {
  // TODO: call dart method to get element property property;
  //  return HostObject::get(<unnamed>, name);
}

void JSElementStyle::set(JSContext &, const PropNameID &name, const Value &value) {
  //  HostObject::set(<unnamed>, name, value);
}

std::vector<PropNameID> JSElementStyle::getPropertyNames(JSContext &context) {
  std::vector<PropNameID> propertyNames;
  return propertyNames;
}

} // namespace binding
} // namespace kraken
