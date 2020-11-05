/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "element.h"
#include <mutex>

namespace kraken::binding::jsc {

void bindDocument(std::unique_ptr<JSContext> &context) {
  auto document = new JSDocument(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Document", document->classObject);
  auto documentObjectRef =
    document->instanceConstructor(context->context(), document->classObject, 0, nullptr, nullptr);
  JSC_GLOBAL_SET_PROPERTY(context, "document", documentObjectRef);
}

JSValueRef JSDocument::createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to createElement: only accept 1 parameter.", exception)
    return nullptr;
  }

  const JSValueRef tagNameValue = arguments[0];
  if (!JSValueIsString(ctx, tagNameValue)) {
    JSC_THROW_ERROR(ctx, "Failed to createElement: tagName should be a string.", exception);
    return nullptr;
  }

  auto document = static_cast<JSDocument *>(JSObjectGetPrivate(function));
  auto element = JSElement::instance(document->context);
  auto elementInstance = JSObjectCallAsConstructor(ctx, element->classObject, 1, arguments, exception);
  return elementInstance;
}

JSDocument::JSDocument(JSContext *context) : JSNode(context, "Document") {}

JSObjectRef JSDocument::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                          const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new DocumentInstance(this);
  return instance->object;
}

JSDocument::DocumentInstance::DocumentInstance(JSDocument *document) : NodeInstance(document, NodeType::DOCUMENT_NODE) {
  auto elementConstructor = JSElement::instance(document->context);
  JSStringRef bodyTagName = JSStringCreateWithUTF8CString("BODY");
  const JSValueRef arguments[] = {
    JSValueMakeString(document->ctx, bodyTagName),
    JSValueMakeNumber(document->ctx, BODY_TARGET_ID)
  };
  body = JSObjectCallAsConstructor(document->ctx, elementConstructor->classObject, 2, arguments, nullptr);
  JSValueProtect(document->ctx, body);
}

JSValueRef JSDocument::DocumentInstance::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);
  if (name == "createElement") {
    return propertyBindingFunction(_hostClass->context, this, "createElement", createElement);
  } else if (name == "body") {
    return body;
  }

  return nullptr;
}

JSDocument::DocumentInstance::~DocumentInstance() {
  JSValueUnprotect(_hostClass->ctx, body);
}

} // namespace kraken::binding::jsc
