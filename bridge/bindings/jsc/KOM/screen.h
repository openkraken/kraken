/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_SCREEN_H
#define KRAKEN_SCREEN_H

#include "bindings/jsc/host_object_internal.h"
#include "bindings/jsc/js_context_internal.h"
#include <array>

namespace kraken::binding::jsc {

#define JSScreenName "Screen"

class JSScreen : public HostObject {
public:
  explicit JSScreen(JSContext *context) : HostObject(context, JSScreenName) {}

  ~JSScreen() override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  std::array<JSStringRef, 4> propertyNames {
    JSStringCreateWithUTF8CString("width"),
    JSStringCreateWithUTF8CString("height"),
    JSStringCreateWithUTF8CString("availWidth"),
    JSStringCreateWithUTF8CString("availHeight"),
  };
};

void bindScreen(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif /* KRAKEN_SCREEN_H */
