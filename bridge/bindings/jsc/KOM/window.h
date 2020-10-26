/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_JS_BINDINGS_WINDOW_H_
#define KRAKEN_JS_BINDINGS_WINDOW_H_

#include "bindings/jsc/js_context.h"
#include "location.h"

#include <array>
#include <memory>

#define JSWindowName "Window"

namespace kraken::binding::jsc {

class JSWindow : public HostObject, std::enable_shared_from_this<JSWindow> {
public:
  JSWindow(JSContext *context)
    : HostObject(context, JSWindowName){
        //    location_ = new JSLocation(context);
        //    location_ = JSObjectMake(context->context(), location->object, location);
      };
  ~JSWindow();

  JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
  //  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  std::shared_ptr<JSWindow> sharedSelf() {
    return shared_from_this();
  }
  //  JSLocation *location_;
  //  std::array<JSStringRef, 3> propertyNames {
  //    JSStringCreateWithUTF8CString("devicePixelRatio"),
  //    JSStringCreateWithUTF8CString("colorScheme"),
  //    JSStringCreateWithUTF8CString("location"),
  //  };
};

void bindWindow(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif
