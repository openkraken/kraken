/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "element.h"
#include "jsa.h"

namespace kraken {
namespace binding {
namespace jsa {

// An persistent createElement function pointer which will recycle JSDocument had been disposed.
static Value *createElementPtr{nullptr};

Value JSDocument::createElement(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count != 1) {
    throw JSError(context, "Failed to createElement: only accept 1 parameter.");
  }

  const Value &tagName = args[0];
  if (!tagName.isString()) {
    throw JSError(context, "Failed to createElement: tagName should be a string.");
  }

  String &&tagNameString = tagName.getString(context);
  NativeString nativeString{};
  nativeString.string = tagNameString.getUnicodePtr(context);
  nativeString.length = tagNameString.unicodeLength(context);

  auto element = Object::createFromHostObject(context, std::make_shared<JSElement>(context, nativeString.clone()));
  return Value(context, element);
}

Value JSDocument::get(JSContext &context, const PropNameID &name) {
  std::string property = name.utf8(context);
  if (property == "createElement") {
    if (createElementPtr == nullptr) {
      createElementPtr = new Value(context, HOST_FUNCTION_TO_VALUE(context, "creatElement", 0, createElement));
    }

    return Value(context, *createElementPtr);
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

JSDocument::~JSDocument() {
  delete createElementPtr;
  createElementPtr = nullptr;
}

void bindDocument(std::unique_ptr<JSContext> &context) {
  auto document = Object::createFromHostObject(*context, std::make_shared<JSDocument>());
  context->global().setProperty(*context, "document", document);
}

}
} // namespace binding
} // namespace kraken
