/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "bridge_qjs.h"

TEST(Context, isValid) {
  auto bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg) {});
  EXPECT_EQ(bridge->getContext()->isValid(), true);
  delete bridge;
}

TEST(Context, evalWithError) {
  auto errorHandler = [](int32_t contextId, const char *errmsg) {
    EXPECT_STREQ(errmsg, "TypeError: cannot read property 'toString' of null\n"
                         "    at <eval> (file://:1)\n");
  };
  auto bridge = new kraken::JSBridge(0, errorHandler);
  const char* code = "let object = null; object.toString();";
  bridge->evaluateScript(code, strlen(code), "file://", 0);
  delete bridge;
}
