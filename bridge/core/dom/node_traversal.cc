/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "node_traversal.h"

namespace kraken {

Node* NodeTraversal::NextAncestorSibling(const Node& current) {
  assert(!current.nextSibling());
  for (Node& parent : AncestorsOf(current)) {
    if (parent.nextSibling())
      return parent.nextSibling();
  }
  return nullptr;
}

Node* NodeTraversal::NextAncestorSibling(const Node& current, const Node* stay_within) {
  assert(!current.nextSibling());
  assert(&current != stay_within);
  for (Node& parent : AncestorsOf(current)) {
    if (&parent == stay_within)
      return nullptr;
    if (parent.nextSibling())
      return parent.nextSibling();
  }
  return nullptr;
}

Node* NodeTraversal::LastWithin(const ContainerNode& current) {
  Node* descendant = current.lastChild();
  for (Node* child = descendant; child; child = child->lastChild())
    descendant = child;
  return descendant;
}

Node& NodeTraversal::LastWithinOrSelf(Node& current) {
  auto* curr_node = DynamicTo<ContainerNode>(current);
  Node* last_descendant = curr_node ? NodeTraversal::LastWithin(*curr_node) : nullptr;
  return last_descendant ? *last_descendant : current;
}

Node* NodeTraversal::Previous(const Node& current, const Node* stay_within) {
  if (&current == stay_within)
    return nullptr;
  if (current.previousSibling()) {
    Node* previous = current.previousSibling();
    while (Node* child = previous->lastChild())
      previous = child;
    return previous;
  }
  return current.parentNode();
}

Node* NodeTraversal::PreviousAbsoluteSibling(const Node& current, const Node* stay_within) {
  for (Node& node : InclusiveAncestorsOf(current)) {
    if (&node == stay_within)
      return nullptr;
    if (Node* prev = node.previousSibling())
      return prev;
  }
  return nullptr;
}

Node* NodeTraversal::NextPostOrder(const Node& current, const Node* stay_within) {
  if (&current == stay_within)
    return nullptr;
  if (!current.nextSibling())
    return current.parentNode();
  Node* next = current.nextSibling();
  while (Node* child = next->firstChild())
    next = child;
  return next;
}

Node* NodeTraversal::PreviousAncestorSiblingPostOrder(const Node& current, const Node* stay_within) {
  assert(!current.previousSibling());
  for (Node& parent : NodeTraversal::AncestorsOf(current)) {
    if (&parent == stay_within)
      return nullptr;
    if (parent.previousSibling())
      return parent.previousSibling();
  }
  return nullptr;
}

Node* NodeTraversal::PreviousPostOrder(const Node& current, const Node* stay_within) {
  if (Node* last_child = current.lastChild())
    return last_child;
  if (&current == stay_within)
    return nullptr;
  if (current.previousSibling())
    return current.previousSibling();
  return PreviousAncestorSiblingPostOrder(current, stay_within);
}

}  // namespace kraken
