/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "jsc_context.h"
#include "gtest/gtest.h"
#include <memory>

using namespace alibaba;

TEST(toSum, toSum_sample_test) {
  std::unique_ptr<alibaba::jsa::JSContext> runtime =
      alibaba::jsc::createJSContext();
  jsa::Object global = runtime->global();
  jsa::Object data = jsa::Object(*runtime);

  jsa::Value left = jsa::Value(2);
  jsa::Value right = jsa::Value(4);

  JSA_SET_PROPERTY(*runtime, global, "data", data);
  JSA_SET_PROPERTY(*runtime, data, "left", left);
  JSA_SET_PROPERTY(*runtime, data, "right", right);

  std::string code = "data.result = data.left + data.right";
  std::string sourceURL;
  runtime->evaluateJavaScript(code.c_str(), sourceURL);

  jsa::Value age = data.getProperty(*runtime, "result");

  EXPECT_EQ(age.asNumber(), 6);
}