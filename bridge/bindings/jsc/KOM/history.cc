/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "history.h"
#include "dart_methods.h"

namespace kraken::binding::jsc {

JSValueRef JSHistory::getProperty(std::string &name, JSValueRef *exception) {
  if (name == "href") {
    NativeString *nativeHref = getDartMethod()->getHref(contextId);
    JSStringRef hrefRef = JSStringCreateWithCharacters(nativeHref->string, nativeHref->length);
    return JSValueMakeString(context->context(), hrefRef);
  }

  return HostObject::getProperty(name, exception);
}

JSHistory::~JSHistory() {
}

} // namespace kraken::binding::jsc
