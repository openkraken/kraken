/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "bindings/jsc/js_context_internal.h"
#include "bindings/jsc/host_object_internal.h"
#include "include/kraken_bridge.h"
#include "node.h"
#include "style_declaration.h"
#include <vector>

namespace kraken::binding::jsc {

void bindElement(std::unique_ptr<JSContext> &context);

using TraverseHandler = std::function<bool(NodeInstance *)>;
void traverseNode(NodeInstance *node, TraverseHandler handler);

} // namespace kraken::binding::jsc
#endif // KRAKENBRIDGE_ELEMENT_H
