/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "tree_scope.h"
#include "container_node.h"

namespace kraken {

TreeScope::TreeScope(ContainerNode& root_node, Document& document) : root_node_(&root_node), document_(&document) {
  root_node.SetTreeScope(this);
}

}  // namespace kraken
