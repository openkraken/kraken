//
// Created by andycall on 2020/9/23.
//

#include "document.h"
#include "element.h"
#include "jsa.h"

namespace kraken {
namespace binding {

Value createElement(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count != 1) {
    throw JSError(context, "Failed to createElement: only accept 1 parameter.");
  }

  const Value &tagName = args[0];
  if (!tagName.isString()) {
    throw JSError(context, "Failed to createElement: tagName should be a string.");
  }

  String &&tagNameString = tagName.getString(context);

  auto element =
    Object::createFromHostObject(context, std::make_shared<JSElement>(context, tagNameString.getUnicodePtr(context),
                                                                      tagNameString.unicodeLength(context)));
  return Value(context, element);
}

Value JSDocument::get(JSContext &context, const PropNameID &name) {
  std::string property = name.utf8(context);
  if (property == "createElement") {
    return Value(context, Function::createFromHostFunction(context, PropNameID::forAscii(context, "createElement"), 2,
                                                           createElement));
  }

  return Value::undefined();
}

void JSDocument::set(JSContext &context, const PropNameID &name, const Value &value) {
  //  HostObject::set(<unnamed>, name, value);
}

std::vector<PropNameID> JSDocument::getPropertyNames(JSContext &context) {
  std::vector<PropNameID> propertyNames;
  // the blob constructor method
  propertyNames.emplace_back(PropNameID::forUtf8(context, "createElement"));
  return propertyNames;
}

void bindDocument(std::unique_ptr<JSContext> &context) {
  auto document = Object::createFromHostObject(*context, std::make_shared<JSDocument>());
  context->global().setProperty(*context, "document", document);
}
} // namespace binding
} // namespace kraken
