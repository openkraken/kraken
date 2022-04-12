/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_CONTAINER_NODE_H_
#define KRAKENBRIDGE_CORE_DOM_CONTAINER_NODE_H_

#include <vector>
#include "bindings/qjs/gc_visitor.h"
#include "node.h"

namespace kraken {

class HTMLCollection;

// This constant controls how much buffer is initially allocated
// for a Node Vector that is used to store child Nodes of a given Node.
const int kInitialNodeVectorSize = 11;
using NodeVector = std::vector<Node*>;

class ContainerNode : public Node {
 public:
  Node* firstChild() const { return first_child_; }
  Node* lastChild() const { return last_child_; }
  bool hasChildren() const { return first_child_; }
  bool HasChildren() const { return first_child_; }

  bool HasOneChild() const { return first_child_ && !first_child_->nextSibling(); }
  bool HasOneTextChild() const { return HasOneChild() && first_child_->IsTextNode(); }
  bool HasChildCount(unsigned) const;

  HTMLCollection* Children();

  unsigned CountChildren() const;

  Node* InsertBefore(Node* new_child, Node* ref_child, ExceptionState&);
  Node* ReplaceChild(Node* new_child, Node* old_child, ExceptionState&);
  Node* RemoveChild(Node* child, ExceptionState&);
  Node* AppendChild(Node* new_child, ExceptionState&);
  bool EnsurePreInsertionValidity(const Node& new_child,
                                  const Node* next,
                                  const Node* old_child,
                                  ExceptionState&) const;

  void RemoveChildren();

  std::string nodeValue() const override;

  virtual bool ChildrenCanHaveStyle() const { return true; }

  void Trace(GCVisitor* visitor) const override;

 protected:
  ContainerNode(Document* document, ConstructionType = kCreateContainer);

  void SetFirstChild(Node* child) { first_child_ = child; }
  void SetLastChild(Node* child) { last_child_ = child; }

 private:
  bool IsContainerNode() const = delete;  // This will catch anyone doing an unnecessary check.
  bool IsTextNode() const = delete;       // This will catch anyone doing an unnecessary check.
  void RemoveBetween(Node* previous_child, Node* next_child, Node& old_child);
  // Inserts the specified nodes before |next|.
  // |next| may be nullptr.
  // |post_insertion_notification_targets| must not be nullptr.
  template <typename Functor>
  void InsertNodeVector(const NodeVector&, Node* next, const Functor&, NodeVector* post_insertion_notification_targets);

  class AdoptAndInsertBefore;
  class AdoptAndAppendChild;
  friend class AdoptAndInsertBefore;
  friend class AdoptAndAppendChild;

  void InsertBeforeCommon(Node& next_child, Node& new_child);
  void AppendChildCommon(Node& child);

  void NotifyNodeInserted(Node&);
  void NotifyNodeInsertedInternal(Node&);
  void NotifyNodeRemoved(Node&);

  inline bool IsChildTypeAllowed(const Node& child) const;
  inline bool IsHostIncludingInclusiveAncestorOfThis(const Node&, ExceptionState&) const;

  Node* first_child_;
  Node* last_child_;
};

inline Node* Node::firstChild() const {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (!this_node)
    return nullptr;
  return this_node->firstChild();
}

inline Node* Node::lastChild() const {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (!this_node) {
    return nullptr;
  }
  return this_node->lastChild();
}

inline bool ContainerNode::HasChildCount(unsigned count) const {
  Node* child = first_child_;
  while (count && child) {
    child = child->nextSibling();
    --count;
  }
  return !count && !child;
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_CONTAINER_NODE_H_
