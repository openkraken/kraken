/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "console.h"
#include "gtest/gtest.h"
#include "page.h"
#include "kraken_bridge.h"
#include "kraken_test_env.h"

TEST(Timer, setTimeout) {

  initJSPagePool(1);
  auto *bridge = static_cast<kraken::KrakenPage*>(getPage(0));

  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    static int logIdx = 0;
    switch(logIdx) {
      case 0:
        EXPECT_STREQ(message.c_str(), "1234");
        break;;
      case 1:
        EXPECT_STREQ(message.c_str(), "789");
        break;
      case 2:
        EXPECT_STREQ(message.c_str(), "456");
        break;
    }

    logIdx++;
  };

  TEST_init(bridge->getContext().get());

  std::string code = R"(
setTimeout(() => {
  console.log('456');
});
new Promise((resolve, reject) => {resolve();}).then(() => { console.log('789') });
console.log('1234');
)";

  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  TEST_runLoop(bridge->getContext().get());
  delete bridge;
}
