/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */


#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "jsa.h"
#include "node.h"
#include "include/kraken_bridge.h"

namespace kraken {
namespace binding {
namespace jsa {
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

}
} // namespace binding
} // namespace kraken
#endif // KRAKENBRIDGE_ELEMENT_H
