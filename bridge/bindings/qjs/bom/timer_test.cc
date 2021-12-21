/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "kraken_bridge.h"
#include "kraken_test_env.h"
#include "page.h"

TEST(Timer, setTimeout) {
  auto bridge = TEST_init();

  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    static int logIdx = 0;
    switch (logIdx) {
      case 0:
        EXPECT_STREQ(message.c_str(), "1234");
        break;
      case 1:
        EXPECT_STREQ(message.c_str(), "789");
        break;
      case 2:
        EXPECT_STREQ(message.c_str(), "456");
        break;
    }

    logIdx++;
  };

  std::string code = R"(
setTimeout(() => {
  console.log('456');
});
new Promise((resolve, reject) => {resolve();}).then(() => { console.log('789') });
console.log('1234');
)";

  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  TEST_runLoop(bridge->getContext().get());
  disposePage(0);
}

TEST(Timer, clearTimeout) {
  auto bridge = TEST_init();

  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  std::string code = R"(
function getCachedData() {
  let index = 0;

  return function() {
    return index++;
  }
}

let timer = setTimeout(async () => {
  let data = getCachedData()();
  console.log(data);
}, 10);
clearTimeout(timer);
)";

  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  TEST_runLoop(bridge->getContext().get());
  disposePage(0);
}
