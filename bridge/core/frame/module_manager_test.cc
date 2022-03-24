/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <gtest/gtest.h>
#include "kraken_test_env.h"

namespace kraken {

TEST(ModuleManager, ShouldReturnCorrectValue) {
  bool static errorCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  auto context = bridge->getContext();

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
let result = kraken.methodChannel.invokeMethod('abc', 'fn', object);
console.log(result);
)");
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(ModuleManager, shouldThrowErrorWhenBadJSON) {
  bool static errorCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    std::string stdErrorMsg = std::string(errmsg);
    EXPECT_EQ(stdErrorMsg.find("TypeError: circular reference") != std::string::npos, true);
    errorCalled = true;
  });
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  auto context = bridge->getContext();

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
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, true);
}

TEST(ModuleManager, invokeModuleError) {
  bool static logCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {});
  kraken::KrakenPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(),
                 "Error {message: 'kraken://', stack: '    at __kraken_invoke_module__ (native)\n"
                 "    at f (vm://:9)\n"
                 "    at <eval> (vm://:11)\n"
                 "'}");
  };

  auto context = bridge->getContext();

  std::string code = std::string(R"(
function f() {
  kraken.invokeModule('throwError', 'kraken://', null, (e, error) => {
    if (e) {
      console.log(e);
    } else {
      console.log('test failed');
    }
  });
}
f();
)");
  context->EvaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(logCalled, true);
}

}  // namespace kraken
