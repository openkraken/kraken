/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "node.h"

namespace kraken::binding::jsc {

JSNode::JSNode(JSContext *context, NodeType nodeType) : JSEventTarget(context, "Node"), nodeType(nodeType) {}

JSNode::JSNode(JSContext *context, const char *name, NodeType nodeType)
  : JSEventTarget(context, name), nodeType(nodeType) {}

} // namespace kraken::binding::jsc
