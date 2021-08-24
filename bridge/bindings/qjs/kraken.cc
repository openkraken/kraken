/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

void bindKraken(std::unique_ptr<JSContext> &context) {
  JSValue krakenObject = JS_NewObject(context->ctx());

  context->defineGlobalProperty("__kraken__", krakenObject);
}
}
