/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken.h"
#include "bindings/jsc/macros.h"
#include "kraken_bridge.h"

namespace kraken::binding::jsc {

void bindKraken(std::unique_ptr<JSContext> &context) {
  JSObjectRef kraken = JSObjectMake(context->context(), nullptr, nullptr);
  KrakenInfo *krakenInfo = getKrakenInfo();

  // Other properties are injected by dart.
  JSStringRef userAgentStr = JSStringCreateWithUTF8CString(krakenInfo->getUserAgent(krakenInfo));
  JSC_SET_STRING_PROPERTY(context, kraken, "userAgent", JSValueMakeString(context->context(), userAgentStr));
  JSC_GLOBAL_SET_PROPERTY(context, "__kraken__", kraken);
}

} // namespace kraken::binding::jsc
