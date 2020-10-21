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
  auto document = new JSDocument(context);
  JSC_BINDING_OBJECT(context, "document", document);
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
  JSStringRef tagNameStrRef = JSValueToStringCopy(ctx, tagNameValue, exception);

  NativeString nativeString{};
  nativeString.string = JSStringGetCharactersPtr(tagNameStrRef);
  nativeString.length = JSStringGetLength(tagNameStrRef);

  auto document = static_cast<JSDocument*>(JSObjectGetPrivate(thisObject));
  auto element = new JSElement(document->context, nativeString.clone());
  return JSObjectMake(element->context->context(), element->object, element);
}

JSDocument::JSDocument(std::unique_ptr<JSContext> &context) : HostObject(context, "Document") {}

JSValueRef JSDocument::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);
  if (name == "createElement") {
    return JSObjectMakeFunctionWithCallback(context->context(), nameRef, createElement);
  }

  return nullptr;
}

void JSDocument::setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) {}

} // namespace kraken::binding::jsc
