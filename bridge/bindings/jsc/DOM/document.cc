/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "element.h"
#include "include/kraken_bridge.h"
#include <mutex>

namespace kraken::binding::jsc {

void bindDocument(std::unique_ptr<JSContext> &context) {
  auto document = new JSDocument(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Document", document->classObject);
//  auto documentObjectRef = JSObjectMake(context->context(), document->instanceClass, document);
//  JSC_GLOBAL_SET_PROPERTY(context, "document", documentObjectRef);
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

JSDocument::JSDocument(JSContext *context) : JSNode(context, "Document", NodeType::DOCUMENT_NODE) {}

JSValueRef JSDocument::instanceGetProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);
  if (name == "createElement") {
    return propertyBindingFunction(context, this, "createElement", createElement);
  }

  return nullptr;
}

} // namespace kraken::binding::jsc
