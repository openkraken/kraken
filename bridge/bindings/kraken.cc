/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken.h"
#include "js_context.h"
#include "kraken_bridge.h"
#include <cassert>

namespace kraken {
namespace binding {

using namespace alibaba::jsa;

void bindKraken(std::unique_ptr<JSContext> &context) {
  auto kraken = JSA_CREATE_OBJECT(*context);

  KrakenInfo *krakenInfo = getKrakenInfo();

  // Other properties are injected by dart.
  JSA_SET_PROPERTY(*context, kraken, "appName", "Kraken");
  JSA_SET_PROPERTY(*context, kraken, "appVersion", std::string(krakenInfo->version));
  JSA_SET_PROPERTY(*context, kraken, "platform", std::string(krakenInfo->platform));
  JSA_SET_PROPERTY(*context, kraken, "product", std::string(krakenInfo->product));
  JSA_SET_PROPERTY(*context, kraken, "productSub", std::string(krakenInfo->product_sub));
  if (krakenInfo->comment != nullptr) {
    JSA_SET_PROPERTY(*context, kraken, "comment", std::string(krakenInfo->comment));
  }
  JSA_SET_PROPERTY(*context, kraken, "userAgent", std::string(krakenInfo->getUserAgent(krakenInfo)));

  JSA_SET_PROPERTY(*context, context->global(), "__kraken__", kraken);
}

} // namespace binding
} // namespace kraken
