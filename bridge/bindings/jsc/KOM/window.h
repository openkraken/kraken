/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_JS_BINDINGS_WINDOW_H_
#define KRAKEN_JS_BINDINGS_WINDOW_H_

#include "bindings/jsc/js_context.h"
#include "location.h"

#include <memory>

#define JSWindowName "Window"

namespace kraken::binding::jsc {

class JSWindow : public HostObject {
public:
  JSWindow(JSContext *context) : HostObject(context, JSWindowName) {
    auto location = new JSLocation(context);
    location_ = JSObjectMake(context->context(), location->object, location);
  };
  JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;

private:
  JSObjectRef location_;
};

void bindWindow(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif
