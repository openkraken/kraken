/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken.h"
#include "js_context.h"
#include "kraken_bridge.h"
#include <cassert>

namespace kraken::binding::jsa {

using namespace alibaba::jsa;

void bindKraken(std::unique_ptr<JSContext> &context) {
  auto kraken = JSA_CREATE_OBJECT(*context);

  KrakenInfo *krakenInfo = getKrakenInfo();

  // Other properties are injected by dart.
  JSA_SET_PROPERTY(*context, kraken, "userAgent", std::string(krakenInfo->getUserAgent(krakenInfo)));
  JSA_SET_PROPERTY(*context, context->global(), "__kraken__", kraken);
}

} // namespace kraken
