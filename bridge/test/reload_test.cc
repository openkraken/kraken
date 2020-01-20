/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#include <memory>

#include "bridge.h"
#include "gtest/gtest.h"
#include "polyfill.h"

namespace kraken {
namespace binding {

using namespace alibaba::jsa;

TEST(reload, first) {
  std::shared_ptr<kraken::JSBridge> bridge = std::make_shared<kraken::JSBridge>();
  bridge->evaluateScript("function a() { return 1;}", "", 0);
  JSContext *context = bridge->getContext();
  initKrakenPolyFill(context);
  Value &&result = bridge->getContext()->evaluateJavaScript("a()", "test://", 0);;
  EXPECT_EQ(result.isNumber(), true);
  EXPECT_EQ(result.getNumber(), 1);
  bridge = std::make_shared<kraken::JSBridge>();
  context = bridge->getContext();
  Value &&another = bridge->getGlobalValue("typeof a");
  EXPECT_EQ(another.isString(), true);
  EXPECT_EQ(another.getString(*context).utf8(*context), "undefined");
}

}
}
