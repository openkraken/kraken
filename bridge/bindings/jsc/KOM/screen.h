/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_SCREEN_H
#define KRAKEN_SCREEN_H

#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

#define JSScreenName "Screen"

class JSScreen : public HostObject {
public:
  explicit JSScreen(JSContext *context) : HostObject(context, JSScreenName) {}

  JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;

private:
};

void bindScreen(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif /* KRAKEN_SCREEN_H */
