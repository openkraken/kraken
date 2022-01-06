/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "node_list.h"

namespace kraken::binding::qjs {

NodeList::NodeList(NodeInstance* parent) : m_parentNode(nullptr) {}

NodeInstance* NodeList::item(unsigned int index) {
  return m_collection_index_cache.nodeAt(*this, index);
}

NodeInstance* NodeList::traverseForwardToOffset(unsigned int offset, NodeInstance& current_node, unsigned int& current_offset) const {
  assert(current_offset < offset);
  //  assert(ownerNode().childNodes() == this);
  //  DCHECK_EQ(&OwnerNode(), current_node.parentNode());
  for (NodeInstance* next = current_node.nextSibling(); next; next = next->nextSibling()) {
    if (++current_offset == offset)
      return next;
  }
  return nullptr;
}

NodeInstance* NodeList::traverseBackwardToOffset(unsigned int offset, NodeInstance& current_node, unsigned int& current_offset) const {
  return nullptr;
}

void NodeList::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {}
void NodeList::dispose() const {}
}  // namespace kraken::binding::qjs
