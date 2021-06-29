/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

void bindKraken(std::unique_ptr<JSContext> &context) {
  JSValue krakenObject = JS_NewObject(context->ctx());
  KrakenInfo *krakenInfo = getKrakenInfo();
  const char *userAgent = krakenInfo->getUserAgent(krakenInfo);
  JSAtom userAgentKey = JS_NewAtom(context->ctx(), "userAgent");
  JS_DefinePropertyValue(context->ctx(), krakenObject, userAgentKey, JS_NewString(context->ctx(), userAgent), JS_PROP_NORMAL);

  context->defineGlobalProperty("__kraken__", krakenObject);
  JS_FreeAtom(context->ctx(), userAgentKey);
}
}
