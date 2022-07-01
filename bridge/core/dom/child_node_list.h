/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_CHILD_NODE_LIST_H_
#define KRAKENBRIDGE_CORE_DOM_CHILD_NODE_LIST_H_

#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/dom/collection_index_cache.h"
#include "core/dom/container_node.h"
#include "core/dom/node_list.h"

namespace kraken {

class ExceptionState;

class ChildNodeList : public NodeList {
 public:
  explicit ChildNodeList(ContainerNode* root_node);
  ~ChildNodeList() override;

  // DOM API.
  unsigned length() const override { return collection_index_cache_.NodeCount(*this); }

  Node* item(unsigned index, ExceptionState& exception_state) const override;

  // Non-DOM API.
  void InvalidateCache() { collection_index_cache_.Invalidate(); }
  ContainerNode& OwnerNode() const { return *parent_.Get(); }

  ContainerNode& RootNode() const { return OwnerNode(); }

  // CollectionIndexCache API.
  bool CanTraverseBackward() const { return true; }
  Node* TraverseToFirst() const { return RootNode().firstChild(); }
  Node* TraverseToLast() const { return RootNode().lastChild(); }
  Node* TraverseForwardToOffset(unsigned offset, Node& current_node, unsigned& current_offset) const;
  Node* TraverseBackwardToOffset(unsigned offset, Node& current_node, unsigned& current_offset) const;

  void Trace(GCVisitor*) const override;

 private:
  bool IsChildNodeList() const override { return true; }
  Node* VirtualOwnerNode() const override;

  Member<ContainerNode> parent_;
  mutable CollectionIndexCache<ChildNodeList, Node> collection_index_cache_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_CHILD_NODE_LIST_H_
