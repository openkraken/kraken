/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "node.h"


namespace kraken {
namespace binding {
using namespace alibaba::jsa;

JSNode::JSNode(JSContext &context, NodeType nodeType): JSEventTarget(context), nodeType(nodeType) {
}


}
}
