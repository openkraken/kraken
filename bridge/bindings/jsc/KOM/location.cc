/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include "bindings/jsc/macros.h"
#include "dart_methods.h"
#include "foundation/logging.h"

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
    return propertyBindingFunction(context, this, "reload", reload);
  } else if (name == "href") {
    JSStringRef hrefRef = JSStringCreateWithUTF8CString(href.c_str());
    return JSValueMakeString(context->context(), hrefRef);
  }

  return nullptr;
}

//void JSLocation::instanceGetPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
//  for (auto &propertyName : propertyNames) {
//    JSPropertyNameAccumulatorAddName(accumulator, propertyName);
//  }
//}

JSLocation::~JSLocation() {
  for (auto &propertyName : propertyNames) {
    JSStringRelease(propertyName);
  }
}

} // namespace kraken::binding::jsc
