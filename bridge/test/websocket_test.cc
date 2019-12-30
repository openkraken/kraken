/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "jsa.h"
#include "jsc_context.h"
#include "websocket.h"
#include "gtest/gtest.h"

TEST(websocket, connect) {
  std::unique_ptr<alibaba::jsa::JSContext> context =
      alibaba::jsc::createJSContext();
  std::shared_ptr<kraken::binding::JSWebSocket> websocket_ =
      std::make_shared<kraken::binding::JSWebSocket>();
  const char *code = "console.log()";
}
