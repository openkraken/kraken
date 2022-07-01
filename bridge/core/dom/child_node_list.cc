/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "child_node_list.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace kraken {

ChildNodeList::ChildNodeList(ContainerNode* parent) : parent_(parent), NodeList(parent->ctx()) {}
ChildNodeList::~ChildNodeList() = default;

Node* ChildNodeList::VirtualOwnerNode() const {
  return &OwnerNode();
}

Node* ChildNodeList::item(unsigned index, ExceptionState& exception_state) const {
  return collection_index_cache_.NodeAt(*this, index);
}

Node* ChildNodeList::TraverseForwardToOffset(unsigned offset, Node& current_node, unsigned& current_offset) const {
  assert(current_offset < offset);
  assert(OwnerNode().childNodes() == this);
  assert(&OwnerNode() == current_node.parentNode());
  for (Node* next = current_node.nextSibling(); next; next = next->nextSibling()) {
    if (++current_offset == offset)
      return next;
  }
  return nullptr;
}

Node* ChildNodeList::TraverseBackwardToOffset(unsigned offset, Node& current_node, unsigned& current_offset) const {
  assert(current_offset > offset);
  assert(OwnerNode().childNodes() == this);
  assert(&OwnerNode() == current_node.parentNode());
  for (Node* previous = current_node.previousSibling(); previous; previous = previous->previousSibling()) {
    if (--current_offset == offset)
      return previous;
  }
  return nullptr;
}

void ChildNodeList::Trace(GCVisitor* visitor) const {
  visitor->Trace(parent_);
  collection_index_cache_.Trace(visitor);
  NodeList::Trace(visitor);
}

}  // namespace kraken
