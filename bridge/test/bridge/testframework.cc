/*
* Copyright (C) 2020-present Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include "gtest/gtest.h"
#include "bridge.h"
#include "jsa.h"

using namespace alibaba;
using namespace jsc;

TEST(TestFramework, evaluteTestFramework) {
  auto handleError = [](const jsa::JSError &error) {
    EXPECT_STREQ(error.what(), "\nAssertionError: false === []\n"
                               "    at global code (internal://:1:19)");
  };

  std::unique_ptr<kraken::JSBridge> bridge = std::make_unique<kraken::JSBridge>(handleError);
  bool result = bridge->evaluteTestScript("assert.strictEqual(false, [])", "internal://", 0);
  EXPECT_EQ(result, false);
}