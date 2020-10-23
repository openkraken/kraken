/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include "dart_methods.h"
#include "foundation/logging.h"
#include "bindings/jsc/macros.h"

namespace kraken::binding::jsc {

std::string href = "";

void updateLocation(std::string url = "") {
  href = url;
}

JSValueRef reload(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                  const JSValueRef arguments[], JSValueRef *exception) {
  auto jsLocation = static_cast<JSLocation *>(JSObjectGetPrivate(function));

  if (getDartMethod()->reloadApp == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'reload': dart method (reloadApp) is not registered.", exception);
    return nullptr;
  }

  getDartMethod()->reloadApp(jsLocation->context->getContextId());

  return nullptr;
};

JSValueRef JSLocation::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);
  if (name == "reload") {
    JSClassDefinition functionDefinition = kJSClassDefinitionEmpty;
    functionDefinition.className = "reload";
    functionDefinition.callAsFunction = reload;
    functionDefinition.version = 0;
    JSClassRef functionClass = JSClassCreate(&functionDefinition);
    JSObjectRef function = JSObjectMake(context->context(), functionClass, this);
    return function;
  } else if (name == "href") {
    JSStringRef hrefRef = JSStringCreateWithUTF8CString(href.c_str());
    return JSValueMakeString(context->context(), hrefRef);
  }

  return nullptr;
}

} // namespace kraken::binding::jsc
