/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */


#ifndef KRAKENBRIDGE_NODE_H
#define KRAKENBRIDGE_NODE_H

#include "jsa.h"
#include "include/kraken_bridge.h"
#include "eventTarget.h"

namespace kraken {
namespace binding {
namespace jsa {
using namespace alibaba::jsa;

enum NodeType {
  ELEMENT_NODE = 1,
  TEXT_NODE = 3,
  COMMENT_NODE = 8,
  DOCUMENT_NODE = 9,
  DOCUMENT_TYPE_NODE = 10,
  DOCUMENT_FRAGMENT_NODE = 11
};

class JSNode : public JSEventTarget {
public:
  JSNode() = delete;
  explicit JSNode(JSContext &context, NodeType nodeType);

private:
  NodeType nodeType;
};

}
}
}

#endif // KRAKENBRIDGE_NODE_H
