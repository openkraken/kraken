/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_METHOD_CHANNEL_H
#define KRAKENBRIDGE_METHOD_CHANNEL_H

#include "bindings/jsc/host_object_internal.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

void bindPerformance(std::unique_ptr<JSContext> &context);

class JSMethodChannel : public HostObject {
public:
  DEFINE_OBJECT_PROPERTY(MethodChannel, 1, invokeMethod);

  JSMethodChannel() = delete;
  explicit JSMethodChannel(JSContext *context);
private:
};

}

#endif // KRAKENBRIDGE_METHOD_CHANNEL_H
