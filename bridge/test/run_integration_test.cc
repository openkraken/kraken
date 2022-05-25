/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include <fstream>
#include "foundation/logging.h"
#include "gtest/gtest.h"
#include "kraken_bridge_test.h"
#include "kraken_test_env.h"
#include "kraken_bridge_test.h"

using namespace kraken;

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

// Run kraken integration test specs with Google Test.
// Very useful to fix bridge bugs.
TEST(IntegrationTest, runSpecs) {
  auto bridge = TEST_init();
  auto context = bridge->GetExecutingContext();

  std::string code = readTestSpec();
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  executeTest(context->contextId(), [](int32_t contextId, void* status) -> void* {
    KRAKEN_LOG(VERBOSE) << "done";
    return nullptr;
  });

  TEST_runLoop(context);
}
