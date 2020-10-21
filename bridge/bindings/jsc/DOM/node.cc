/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "node.h"

namespace kraken::binding::jsc {

JSNode::JSNode(std::unique_ptr<JSContext> &context, NodeType nodeType) : JSEventTarget(context, "Node"), nodeType(nodeType) {}

JSNode::JSNode(std::unique_ptr<JSContext> &context, const char *name, NodeType nodeType)
  : JSEventTarget(context, name), nodeType(nodeType) {}

} // namespace kraken::binding::jsc
