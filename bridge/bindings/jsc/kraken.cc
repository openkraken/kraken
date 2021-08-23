/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken.h"
#include "bindings/jsc/js_context_internal.h"
#include "kraken_bridge.h"
#include <unordered_map>

namespace kraken::binding::jsc {

void bindKraken(std::unique_ptr<JSContext> &context) {
  JSObjectRef kraken = JSObjectMake(context->context(), nullptr, nullptr);
  KrakenInfo *krakenInfo = getKrakenInfo();
  JSValueProtect(context->context(), kraken);

  // Other properties are injected by dart.
  JSC_GLOBAL_SET_PROPERTY(context, "__kraken__", kraken);
}

} // namespace kraken::binding::jsc
