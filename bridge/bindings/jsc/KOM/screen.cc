/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "screen.h"
#include "dart_methods.h"

namespace kraken::binding::jsc {

JSValueRef JSScreen::getProperty(std::string &name, JSValueRef *exception) {
  if (getDartMethod(context->getOwner())->getScreen == nullptr) {
    throwJSError(context->context(), "Failed to read screen: dart method (getScreen) is not registered.", exception);
    return nullptr;
  }

  Screen *screen = getDartMethod(context->getOwner())->getScreen(context->getContextId());

  if (name == "width" || name == "availWidth") {
    return JSValueMakeNumber(context->context(), screen->width);
  } else if (name == "height" || name == "availHeight") {
    return JSValueMakeNumber(context->context(), screen->height);
  }

  return HostObject::getProperty(name, exception);
}

void JSScreen::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &propertyName : propertyNames) {
    JSPropertyNameAccumulatorAddName(accumulator, propertyName);
  }
}

JSScreen::~JSScreen() {
  for (auto &propertyName : propertyNames) {
    JSStringRelease(propertyName);
  }
}

void bindScreen(std::unique_ptr<JSContext> &context) {
  auto screen = new JSScreen(context.get());
  JSC_GLOBAL_BINDING_HOST_OBJECT(context, "screen", screen);
}

} // namespace kraken::binding::jsc
