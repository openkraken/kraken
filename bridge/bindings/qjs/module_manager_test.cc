/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <gtest/gtest.h>
#include "executing_context.h"
#include "host_object.h"
#include "kraken_test_env.h"
#include "page.h"

namespace kraken::binding::qjs {

TEST(ModuleManager, shouldThrowErrorWhenBadJSON) {
  bool static errorCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    std::string stdErrorMsg = std::string(errmsg);
    EXPECT_EQ(stdErrorMsg.find("TypeError: circular reference") != std::string::npos, true);
    errorCalled = true;
  });
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  auto& context = bridge->getContext();

  std::string code = std::string(R"(
let object = {
    key: {
        v: {
            a: {
                other: null
            }
        }
    }
};
object.other = object;
kraken.methodChannel.invokeMethod('abc', 'fn', object);
)");
  context->evaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, true);
}

}  // namespace kraken::binding::qjs
