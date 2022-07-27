/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <fstream>
#include "gtest/gtest.h"
#include "page.h"
#include "webf_bridge_test.h"
#include "webf_test_env.h"

std::string readTestSpec() {
  std::string filepath = std::string(SPEC_FILE_PATH) + "/../integration_tests/.specs/core.build.js";

  std::ifstream file;
  file.open(filepath);

  std::string content;
  if (file.is_open()) {
    std::string line;
    while (std::getline(file, line)) {
      content += line + "\n";
    }
    file.close();
  }

  return content;
}

// Run webf integration test specs with Google Test.
// Very useful to fix bridge bugs.
TEST(IntegrationTest, runSpecs) {
  auto bridge = TEST_init();
  auto context = bridge->getContext();

  std::string code = readTestSpec();
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  executeTest(context->getContextId(), [](int32_t contextId, NativeString* status) -> void* { WEBF_LOG(VERBOSE) << "done"; });

  TEST_runLoop(context);
}
