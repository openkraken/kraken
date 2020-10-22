/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "screen.h"
#include "dart_methods.h"
#include "bindings/jsc/macros.h"

namespace kraken::binding::jsc {

JSValueRef JSScreen::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);

  if (getDartMethod()->getScreen == nullptr) {
    JSC_THROW_ERROR(context->context(), "Failed to read screen: dart method (getScreen) is not registered.", exception);
    return nullptr;
  }

  Screen *screen = getDartMethod()->getScreen(context->getContextId());

  if (name == "width" || name == "availWidth") {
    return JSValueMakeNumber(context->context(), screen->width);
  } else if (name == "height" || name == "availHeight") {
    return JSValueMakeNumber(context->context(), screen->height);
  }

  return nullptr;
}

void bindScreen(std::unique_ptr<JSContext> &context) {
  auto screen = new JSScreen(context.get());
  JSC_GLOBAL_BINDING_HOST_OBJECT(context, "screen", screen);
}

} // namespace kraken::binding::jsc
