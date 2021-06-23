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
    EXPECT_STREQ(errmsg, "ReferenceError: 'document' is not defined\n"
                      "    at <anonymous> (internal://:3)\n"
                      "    at <eval> (internal://:2516)\n");
  };
  auto bridge = new kraken::JSBridge(0, errorHandler);
  std::u16string code = u"let a = 1;";
  bridge->evaluateScript(code, "file://", 0);
  delete bridge;
}
