/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include "dart_methods.h"

namespace kraken::binding::jsc {

JSValueRef JSLocation::getProperty(std::string &name, JSValueRef *exception) {
  if (name == "href") {
    NativeString *nativeHref = getDartMethod(context->getOwner())->getHref(contextId);
    JSStringRef hrefRef = JSStringCreateWithCharacters(nativeHref->string, nativeHref->length);
    return JSValueMakeString(context->context(), hrefRef);
  }

  return HostObject::getProperty(name, exception);
}

JSLocation::~JSLocation() {
  for (auto &propertyName : propertyNames) {
    JSStringRelease(propertyName);
  }
}

JSValueRef JSLocation::reload(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef *arguments, JSValueRef *exception) {
  auto jsLocation = static_cast<JSLocation *>(JSObjectGetPrivate(function));

  if (getDartMethod(jsLocation->context->getOwner())->reloadApp == nullptr) {
    throwJSError(ctx, "Failed to execute 'reload': dart method (reloadApp) is not registered.", exception);
    return nullptr;
  }

  getDartMethod(jsLocation->context->getOwner())->flushUICommand();
  getDartMethod(jsLocation->context->getOwner())->reloadApp(jsLocation->context->getContextId());

  return nullptr;
}

} // namespace kraken::binding::jsc
