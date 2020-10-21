/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "include/kraken_bridge.h"
#include "node.h"

namespace kraken::binding::jsc {

class JSElement : public JSNode {
public:
  JSElement() = delete;
  explicit JSElement(JSContext *context, NativeString *tagName);

private:
};

} // namespace kraken::binding::jsc
#endif // KRAKENBRIDGE_ELEMENT_H
