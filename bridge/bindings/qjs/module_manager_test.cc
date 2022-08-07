/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <gtest/gtest.h>
#include "executing_context.h"
#include "host_object.h"
#include "page.h"
#include "webf_test_env.h"

namespace webf::binding::qjs {

TEST(ModuleManager, shouldThrowErrorWhenBadJSON) {
  bool static errorCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    std::string stdErrorMsg = std::string(errmsg);
    EXPECT_EQ(stdErrorMsg.find("TypeError: circular reference") != std::string::npos, true);
    errorCalled = true;
  });
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

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
webf.methodChannel.invokeMethod('abc', 'fn', object);
)");
  context->evaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, true);
}

TEST(ModuleManager, invokeModuleError) {
  bool static logCalled = false;
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {});
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(),
                 "Error {message: 'webf://', stack: '    at __webf_invoke_module__ (native)\n"
                 "    at f (vm://:9)\n"
                 "    at <eval> (vm://:11)\n"
                 "'}");
  };

  auto context = bridge->getContext();

  std::string code = std::string(R"(
function f() {
  webf.invokeModule('throwError', 'webf://', null, (e, error) => {
    if (e) {
      console.log(e);
    } else {
      console.log('test failed');
    }
  });
}
f();
)");
  context->evaluateJavaScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(logCalled, true);
}

}  // namespace webf::binding::qjs
