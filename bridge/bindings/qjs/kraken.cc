/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

void bindKraken(std::unique_ptr<JSContext> &context) {
  JSValue krakenObject = JS_NewObject(context->context());
  KrakenInfo *krakenInfo = getKrakenInfo();
  const char *userAgent = krakenInfo->getUserAgent(krakenInfo);
  JS_DefinePropertyValue(context->context(), krakenObject, JS_NewAtom(context->context(), "userAgent"), JS_NewString(context->context(), userAgent), JS_PROP_NORMAL);
  JS_DefinePropertyValue(context->context(), context->global(), JS_NewAtom(context->context(), "__kraken__"), krakenObject, JS_PROP_NORMAL);
}
}
