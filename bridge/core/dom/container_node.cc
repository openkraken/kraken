/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "container_node.h"
#include "bindings/qjs/garbage_collected.h"
#include "document_fragment.h"
#include "node_traversal.h"

namespace kraken {

HTMLCollection* ContainerNode::Children() {
  //TODO: add children implements.
  return nullptr;
}

unsigned ContainerNode::CountChildren() const {
  unsigned count = 0;
  for (Node* node = firstChild(); node; node = node->nextSibling())
    count++;
  return count;
}

inline void GetChildNodes(ContainerNode& node, NodeVector& nodes) {
  assert(!nodes.size());
  for (Node* child = node.firstChild(); child; child = child->nextSibling())
    nodes.push_back(child);
}

class ContainerNode::AdoptAndInsertBefore {
 public:
  inline void operator()(ContainerNode& container, Node& child, Node* next) const {
    assert(next);
    assert(next->parentNode() == &container);
    container.InsertBeforeCommon(*next, child);
  }
};

class ContainerNode::AdoptAndAppendChild {
 public:
  inline void operator()(ContainerNode& container, Node& child, Node*) const { container.AppendChildCommon(child); }
};

bool ContainerNode::IsChildTypeAllowed(const Node& child) const {
  auto* child_fragment = DynamicTo<DocumentFragment>(child);
  if (!child_fragment)
    return ChildTypeAllowed(child.nodeType());

  for (Node* node = child_fragment->firstChild(); node; node = node->nextSibling()) {
    if (!ChildTypeAllowed(node->nodeType()))
      return false;
  }
  return true;
}

// Returns true if |new_child| contains this node. In that case,
// |exception_state| has an exception.
// https://dom.spec.whatwg.org/#concept-tree-host-including-inclusive-ancestor
bool ContainerNode::IsHostIncludingInclusiveAncestorOfThis(const Node& new_child,
                                                           ExceptionState& exception_state) const {
  // Non-ContainerNode can contain nothing.
  if (!new_child.IsContainerNode())
    return false;

  bool child_contains_parent = false;
  const Node& root = TreeRoot();
  auto* fragment = DynamicTo<DocumentFragment>(root);
  if (fragment && fragment->IsTemplateContent()) {
    child_contains_parent = new_child.ContainsIncludingHostElements(*this);
  } else {
    child_contains_parent = new_child.contains(this, exception_state);
  }
  if (child_contains_parent) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "The new child element contains the parent.");
  }
  return child_contains_parent;
}

inline bool CheckReferenceChildParent(const Node& parent,
                                      const Node* next,
                                      const Node* old_child,
                                      ExceptionState& exception_state) {
  if (next && next->parentNode() != &parent) {
    exception_state.ThrowException(next->ctx(), ErrorType::TypeError,
                                   "The node before which the new node is "
                                   "to be inserted is not a child of this "
                                   "node.");
    return false;
  }
  if (old_child && old_child->parentNode() != &parent) {
    exception_state.ThrowException(old_child->ctx(), ErrorType::TypeError,
                                   "The node to be replaced is not a child of this node.");
    return false;
  }
  return true;
}

// This dispatches various events; DOM mutation events, blur events, IFRAME
// unload events, etc.
// Returns true if DOM mutation should be proceeded.
static inline bool CollectChildrenAndRemoveFromOldParent(Node& node,
                                                         NodeVector& nodes,
                                                         ExceptionState& exception_state) {
  if (auto* fragment = DynamicTo<DocumentFragment>(node)) {
    GetChildNodes(*fragment, nodes);
    fragment->RemoveChildren();
    return !nodes.empty();
  }
  nodes.push_back(&node);
  if (ContainerNode* old_parent = node.parentNode())
    old_parent->RemoveChild(&node, exception_state);
  return !exception_state.HasException() && !nodes.empty();
}

Node* ContainerNode::InsertBefore(Node* new_child, Node* ref_child, ExceptionState& exception_state) {
  assert(new_child);
  // https://dom.spec.whatwg.org/#concept-node-pre-insert

  // insertBefore(node, null) is equivalent to appendChild(node)
  if (!ref_child)
    return AppendChild(new_child, exception_state);

  // 1. Ensure pre-insertion validity of node into parent before child.
  if (!EnsurePreInsertionValidity(*new_child, ref_child, nullptr, exception_state))
    return new_child;

  // 2. Let reference child be child.
  // 3. If reference child is node, set it to node’s next sibling.
  if (ref_child == new_child) {
    ref_child = new_child->nextSibling();
    if (!ref_child)
      return AppendChild(new_child, exception_state);
  }

  // 4. Adopt node into parent’s node document.
  NodeVector targets;
  targets.reserve(kInitialNodeVectorSize);
  if (!CollectChildrenAndRemoveFromOldParent(*new_child, targets, exception_state))
    return new_child;

  // 5. Insert node into parent before reference child.
  NodeVector post_insertion_notification_targets;
  post_insertion_notification_targets.reserve(kInitialNodeVectorSize);
  return new_child;
}

Node* ContainerNode::ReplaceChild(Node* new_child, Node* old_child, ExceptionState& exception_state) {
  assert(new_child);
  // https://dom.spec.whatwg.org/#concept-node-replace

  if (!old_child) {
    exception_state.ThrowException(new_child->ctx(), ErrorType::TypeError, "The node to be replaced is null.");
    return nullptr;
  }

  // Step 2 to 6.
  if (!EnsurePreInsertionValidity(*new_child, nullptr, old_child, exception_state))
    return old_child;

  // 7. Let reference child be child’s next sibling.
  Node* next = old_child->nextSibling();
  // 8. If reference child is node, set it to node’s next sibling.
  if (next == new_child)
    next = new_child->nextSibling();

  // 10. Adopt node into parent’s node document.
  // Though the following CollectChildrenAndRemoveFromOldParent() also calls
  // RemoveChild(), we'd like to call RemoveChild() here to make a separated
  // MutationRecord.
  if (ContainerNode* new_child_parent = new_child->parentNode()) {
    new_child_parent->RemoveChild(new_child, exception_state);
    if (exception_state.HasException())
      return nullptr;
  }

  NodeVector targets;
  targets.reserve(kInitialNodeVectorSize);
  NodeVector post_insertion_notification_targets;
  post_insertion_notification_targets.reserve(kInitialNodeVectorSize);
  {
    // 9. Let previousSibling be child’s previous sibling.
    // 11. Let removedNodes be the empty list.
    // 15. Queue a mutation record of "childList" for target parent with
    // addedNodes nodes, removedNodes removedNodes, nextSibling reference child,
    // and previousSibling previousSibling.

    // 12. If child’s parent is not null, run these substeps:
    //    1. Set removedNodes to a list solely containing child.
    //    2. Remove child from its parent with the suppress observers flag set.
    if (ContainerNode* old_child_parent = old_child->parentNode()) {
      old_child_parent->RemoveChild(old_child, exception_state);
      if (exception_state.HasException())
        return nullptr;
    }

    // 13. Let nodes be node’s children if node is a DocumentFragment node, and
    // a list containing solely node otherwise.
    if (!CollectChildrenAndRemoveFromOldParent(*new_child, targets, exception_state))
      return old_child;
    // 10. Adopt node into parent’s node document.
    // 14. Insert node into parent before reference child with the suppress
    // observers flag set.
    if (next) {
      InsertNodeVector(targets, next, AdoptAndInsertBefore(), &post_insertion_notification_targets);
    } else {
      InsertNodeVector(targets, nullptr, AdoptAndAppendChild(), &post_insertion_notification_targets);
    }
  }

  // 16. Return child.
  return old_child;
}

Node* ContainerNode::RemoveChild(Node* old_child, ExceptionState& exception_state) {
  // NotFoundError: Raised if oldChild is not a child of this node.
  if (!old_child || old_child->parentNode() != this) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "The node to be removed is not a child of this node.");
    return nullptr;
  }

  Node* child = old_child;

  // Events fired when blurring currently focused node might have moved this
  // child into a different parent.
  if (child->parentNode() != this) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "The node to be removed is no longer a "
                                   "child of this node. Perhaps it was moved "
                                   "in a 'blur' event handler?");
    return nullptr;
  }

  {
    Node* prev = child->previousSibling();
    Node* next = child->nextSibling();
    { RemoveBetween(prev, next, *child); }
  }
  return child;
}

Node* ContainerNode::AppendChild(Node* new_child, ExceptionState& exception_state) {
  assert(new_child);
  // Make sure adding the new child is ok
  if (!EnsurePreInsertionValidity(*new_child, nullptr, nullptr, exception_state))
    return new_child;

  NodeVector targets;
  targets.reserve(kInitialNodeVectorSize);
  if (!CollectChildrenAndRemoveFromOldParent(*new_child, targets, exception_state))
    return new_child;

  NodeVector post_insertion_notification_targets;
  post_insertion_notification_targets.reserve(kInitialNodeVectorSize);
  { InsertNodeVector(targets, nullptr, AdoptAndAppendChild(), &post_insertion_notification_targets); }
  return new_child;
}

bool ContainerNode::EnsurePreInsertionValidity(const Node& new_child,
                                               const Node* next,
                                               const Node* old_child,
                                               ExceptionState& exception_state) const {
  assert(!(next && old_child));

  // Use common case fast path if possible.
  if ((new_child.IsElementNode() || new_child.IsTextNode()) && IsElementNode()) {
    assert(IsChildTypeAllowed(new_child));
    // 2. If node is a host-including inclusive ancestor of parent, throw a
    // HierarchyRequestError.
    if (IsHostIncludingInclusiveAncestorOfThis(new_child, exception_state))
      return false;
    // 3. If child is not null and its parent is not parent, then throw a
    // NotFoundError.
    return CheckReferenceChildParent(*this, next, old_child, exception_state);
  }

//  if (auto* document = DynamicTo<Document>(this)) {
//    // Step 2 is unnecessary. No one can have a Document child.
//    // Step 3:
//    if (!CheckReferenceChildParent(*this, next, old_child, exception_state))
//      return false;
//    // Step 4-6.
//    return document->CanAcceptChild(new_child, next, old_child, exception_state);
//  }

  // 2. If node is a host-including inclusive ancestor of parent, throw a
  // HierarchyRequestError.
  if (IsHostIncludingInclusiveAncestorOfThis(new_child, exception_state))
    return false;

  // 3. If child is not null and its parent is not parent, then throw a
  // NotFoundError.
  if (!CheckReferenceChildParent(*this, next, old_child, exception_state))
    return false;

  // 4. If node is not a DocumentFragment, DocumentType, Element, Text,
  // ProcessingInstruction, or Comment node, throw a HierarchyRequestError.
  // 5. If either node is a Text node and parent is a document, or node is a
  // doctype and parent is not a document, throw a HierarchyRequestError.
  if (!IsChildTypeAllowed(new_child)) {
    exception_state.ThrowException(
        ctx(), ErrorType::TypeError,
        "Nodes of type '" + new_child.nodeName() + "' may not be inserted inside nodes of type '" + nodeName() + "'.");
    return false;
  }

  // Step 6 is unnecessary for non-Document nodes.
  return true;
}

void ContainerNode::RemoveChildren() {
  if (!first_child_)
    return;

  while (Node* child = first_child_) {
    RemoveBetween(nullptr, child->nextSibling(), *child);
  }
}

ContainerNode::ContainerNode(Document* document, ConstructionType type) : Node(document, type) {}

void ContainerNode::RemoveBetween(Node* previous_child, Node* next_child, Node& old_child) {
  assert(old_child.parentNode() == this);

  if (next_child)
    next_child->SetPreviousSibling(previous_child);
  if (previous_child)
    previous_child->SetNextSibling(next_child);
  if (first_child_ == &old_child)
    SetFirstChild(next_child);
  if (last_child_ == &old_child)
    SetLastChild(previous_child);

  old_child.SetPreviousSibling(nullptr);
  old_child.SetNextSibling(nullptr);
  old_child.SetParentOrShadowHostNode(nullptr);
}

template <typename Functor>
void ContainerNode::InsertNodeVector(const NodeVector& targets,
                                     Node* next,
                                     const Functor& mutator,
                                     NodeVector* post_insertion_notification_targets) {
  assert(post_insertion_notification_targets);
  {
    for (const auto& target_node : targets) {
      assert(target_node);
      assert(!target_node->parentNode());
      Node& child = *target_node;
      mutator(*this, child, next);
    }
  }
}

void ContainerNode::InsertBeforeCommon(Node& next_child, Node& new_child) {
  // Use insertBefore if you need to handle reparenting (and want DOM mutation
  // events).
  assert(!new_child.parentNode());
  assert(!new_child.nextSibling());
  assert(!new_child.previousSibling());

  Node* prev = next_child.previousSibling();
  assert(last_child_ != prev);
  next_child.SetPreviousSibling(&new_child);
  if (prev) {
    assert(firstChild() != &next_child);
    assert(prev->nextSibling() == &next_child);
    prev->SetNextSibling(&new_child);
  } else {
    assert(firstChild() == &next_child);
    SetFirstChild(&new_child);
  }
  new_child.SetParentOrShadowHostNode(this);
  new_child.SetPreviousSibling(prev);
  new_child.SetNextSibling(&next_child);
}

void ContainerNode::AppendChildCommon(Node& child) {
  child.SetParentOrShadowHostNode(this);
  if (last_child_) {
    child.SetPreviousSibling(last_child_);
    last_child_->SetNextSibling(&child);
  } else {
    SetFirstChild(&child);
  }
  SetLastChild(&child);
}

void ContainerNode::NotifyNodeInserted(Node& root) {
  NotifyNodeInsertedInternal(root);
}

void ContainerNode::NotifyNodeInsertedInternal(Node& root) {
  for (Node& node : NodeTraversal::InclusiveDescendantsOf(root)) {
    // As an optimization we don't notify leaf nodes when when inserting
    // into detached subtrees that are not in a shadow tree.
    if (!isConnected() && !node.IsContainerNode())
      continue;
  }
}

void ContainerNode::NotifyNodeRemoved(Node& root) {
  for (Node& node : NodeTraversal::InclusiveDescendantsOf(root)) {
    // As an optimization we skip notifying Text nodes and other leaf nodes
    // of removal when they're not in the Document tree and not in a shadow root
    // since the virtual call to removedFrom is not needed.
    if (!node.IsContainerNode() && !node.IsInTreeScope())
      continue;
    node.RemovedFrom(*this);
  }
}

void ContainerNode::Trace(GCVisitor* visitor) const {
  Node::Trace(visitor);
}

}  // namespace kraken
