/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifdef KRAKEN_JSC_ENGINE

#include "jsa.h"
#include "jsc/jsc_implementation.h"
#include "gtest/gtest.h"
#include <memory>

using namespace alibaba;
using namespace jsc;

namespace {
void normalPrint(alibaba::jsa::JSContext &context, const jsa::JSError &error) {
  std::cerr << error.what() << std::endl;
  FAIL();
}
}


TEST(multiple_context, initJSEngine) {
  std::unique_ptr<alibaba::jsa::JSContext> contextA = createJSContext(0, normalPrint);
  std::unique_ptr<alibaba::jsa::JSContext> contextB = createJSContext(1, normalPrint);

  contextA->global().setProperty(*contextA, "name", jsa::Value(1));
  EXPECT_EQ(contextB->global().getProperty(*contextB, "name").isUndefined(), true);
  EXPECT_EQ(contextA->global().getProperty(*contextA, "name").isUndefined(), false);
  EXPECT_EQ(contextA->global().getProperty(*contextA, "name").getNumber(), 1);
}

#endif