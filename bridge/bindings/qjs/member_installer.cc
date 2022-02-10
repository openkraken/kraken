/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "member_installer.h"

namespace kraken {

int combinePropFlags(JSPropFlag a, JSPropFlag b) {
  return a | b;
}
int combinePropFlags(JSPropFlag a, JSPropFlag b, JSPropFlag c) {
  return a | b | c;
}

void MemberInstaller::installAttributes(JSContext* ctx, JSValue root, std::initializer_list<MemberInstaller::AttributeConfig> config) {
  for (auto& c : config) {
    JS_DefinePropertyValueStr(ctx, root, c.name, JS_DupValue(ctx, c.value), c.flag);
  }
}

void MemberInstaller::installFunctions(JSContext* ctx, JSValue root, std::initializer_list<FunctionConfig> config) {
  for (auto& c : config) {
    JSValue function = JS_NewCFunction(ctx, c.function, c.name, c.length);
    JS_DefinePropertyValueStr(ctx, root, c.name, function, c.flag);
  }
}

}  // namespace kraken
