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
  JSC_GLOBAL_BINDING_HOST_OBJECT(context, "document", document);
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

  auto document = static_cast<JSDocument *>(JSObjectGetPrivate(function));
  auto element = new JSElement(document->context, nativeString.clone());

  JSStringRelease(tagNameStrRef);
  return element->jsObject;
}

JSDocument::JSDocument(JSContext *context) : HostObject(context, "Document") {}

JSValueRef JSDocument::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);
  if (name == "createElement") {
    return JSDocument::propertyBindingFunction(context, this, "createElement", createElement);
  }

  return nullptr;
}

void JSDocument::setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) {}

} // namespace kraken::binding::jsc
