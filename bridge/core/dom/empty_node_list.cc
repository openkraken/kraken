/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "empty_node_list.h"
#include "core/dom/node.h"

namespace kraken {

EmptyNodeList::EmptyNodeList(Node* root_node) : owner_(root_node), NodeList(root_node->ctx()) {}

void EmptyNodeList::Trace(GCVisitor* visitor) const {}

Node* EmptyNodeList::VirtualOwnerNode() const {
  return &OwnerNode();
}

}  // namespace kraken
