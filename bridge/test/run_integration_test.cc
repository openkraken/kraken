/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include "page.h"
#include "kraken_test_env.h"
#include "kraken_bridge_test.h"
#include <fstream>

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

TEST(IntegrationTest, runSpecs) {
  initJSPagePool(1);
  initTestFramework(0);

  auto* bridge = static_cast<kraken::KrakenPage*>(getPage(0));

  auto& context = bridge->getContext();

  TEST_init(context.get());

  std::string code = readTestSpec();
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  executeTest(context->getContextId(), [](int32_t contextId, NativeString* status) -> void* {
    KRAKEN_LOG(VERBOSE) << "done";
  });

  TEST_runLoop(context.get());
  disposePage(0);
}
