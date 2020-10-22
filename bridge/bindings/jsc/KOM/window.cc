/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "bindings/jsc/macros.h"
#include "dart_methods.h"

namespace kraken::binding::jsc {

JSValueRef JSWindow::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);

  if (name == "devicePixelRatio") {
    if (getDartMethod()->devicePixelRatio == nullptr) {
      JSC_THROW_ERROR(context->context(),
                      "Failed to read devicePixelRatio: dart method (devicePixelRatio) is not register.", exception);
      return nullptr;
    }

    double devicePixelRatio = getDartMethod()->devicePixelRatio(context->getContextId());
    return JSValueMakeNumber(context->context(), devicePixelRatio);
  } else if (name == "colorScheme") {
    if (getDartMethod()->platformBrightness == nullptr) {
      JSC_THROW_ERROR(context->context(), "Failed to read colorScheme: dart method (platformBrightness) not register.", exception);
      return nullptr;
    }
    const NativeString *code = getDartMethod()->platformBrightness(context->getContextId());
    JSStringRef resultRef = JSStringCreateWithCharacters(code->string, code->length);
    return JSValueMakeString(context->context(), resultRef);
  } else if (name == "location") {
    return location_;
  }

  return nullptr;
}

void bindWindow(std::unique_ptr<JSContext> &context) {
  auto window = new JSWindow(context.get());
  JSC_GLOBAL_BINDING_HOST_OBJECT(context, "__kraken_window__", window);
}
} // namespace kraken::binding::jsc
