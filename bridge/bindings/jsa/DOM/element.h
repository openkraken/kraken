/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "include/kraken_bridge.h"
#include "jsa.h"
#include "node.h"

namespace kraken::binding::jsa {
using namespace alibaba::jsa;

class JSElement : public JSNode {
public:
  JSElement() = delete;
  explicit JSElement(JSContext &context, NativeString *tagName);

  Value get(JSContext &, const PropNameID &name) override;

  void set(JSContext &, const PropNameID &name, const Value &value) override;

  std::vector<PropNameID> getPropertyNames(JSContext &context) override;

private:
};

} // namespace kraken::binding::jsa
#endif // KRAKENBRIDGE_ELEMENT_H
