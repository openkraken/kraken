/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_ELEMENT_TRAVERSAL_H_
#define KRAKENBRIDGE_CORE_DOM_ELEMENT_TRAVERSAL_H_

#include "element.h"
#include "foundation/macros.h"
#include "html_element_type_helper.h"
#include "node_traversal.h"
#include "traversal_range.h"

namespace kraken {

class HasTagName {
  KRAKEN_STACK_ALLOCATED();

 public:
  explicit HasTagName(const AtomicString& tag_name) : tag_name_(tag_name) {}
  bool operator()(const Element& element) const { return element.HasTagName(tag_name_); }

 private:
  const AtomicString tag_name_;
};

// This class is used to traverse the DOM tree. It isn't meant to be
// constructed; instead, callers invoke the static methods, after templating it
// so that ElementType is the type of element they are interested in traversing.
// Traversals can also be predicated on a matcher, which will be used to
// filter the returned elements. A matcher is a callable - an object of a class
// that defines operator(). HasTagName above is an example of a matcher.
//
// For example, a caller could do this:
//   Traversal<Element>::firstChild(some_node,
//                                  HasTagName(html_names::kTitleTag));
//
// This invocation would return the first child of |some_node| (which has to be
// a ContainerNode) for which HasTagName(html_names::kTitleTag) returned true,
// so it would return the first child of |someNode| which is a <title> element.
// If the caller needs to traverse a Node this way, it's necessary to first
// check Node::IsContainerNode() and then use To<ContainerNode>(). Another way
// to achieve same behaviour is to use DynamicTo<ContainerNode>() which
// checks Node::IsContainerNode() and then returns container
// node. If the conditional check fails then it returns nullptr.
// DynamicTo<ContainerNode>() wraps IsContainerNode() so there is no need of
// an explicit conditional check.
//
// When looking for a specific element type, it is more efficient to do this:
//   Traversal<HTMLTitleElement>::firstChild(someNode);
//
// Traversal can also be used to find ancestors and descendants; see the
// documentation in the class body below.
//
// Note that these functions do not traverse into child shadow trees of any
// shadow hosts they encounter. If you need to traverse the shadow DOM, you can
// manually traverse the shadow trees using a second Traversal, or use
// FlatTreeTraversal.
//
// ElementTraversal is a specialized version of Traversal<Element>.
template <class ElementType>
class Traversal {
  KRAKEN_STATIC_ONLY(Traversal);

 public:
  using TraversalNodeType = ElementType;
  // First or last ElementType child of the node.
  static ElementType* FirstChild(const ContainerNode& current) { return FirstChildTemplate(current); }
  static ElementType* FirstChild(const Node& current) { return FirstChildTemplate(current); }
  template <class MatchFunc>
  static ElementType* FirstChild(const ContainerNode&, MatchFunc);
  static ElementType* LastChild(const ContainerNode& current) { return LastChildTemplate(current); }
  static ElementType* LastChild(const Node& current) { return LastChildTemplate(current); }
  template <class MatchFunc>
  static ElementType* LastChild(const ContainerNode&, MatchFunc);

  // First ElementType ancestor of the node.
  static ElementType* FirstAncestor(const Node& current);
  static ElementType* FirstAncestorOrSelf(Node& current) { return FirstAncestorOrSelfTemplate(current); }
  static ElementType* FirstAncestorOrSelf(Element& current) { return FirstAncestorOrSelfTemplate(current); }
  static const ElementType* FirstAncestorOrSelf(const Node& current) {
    return FirstAncestorOrSelfTemplate(const_cast<Node&>(current));
  }
  static const ElementType* FirstAncestorOrSelf(const Element& current) {
    return FirstAncestorOrSelfTemplate(const_cast<Element&>(current));
  }

  // First or last ElementType descendant of the node.
  // For pure Elements firstWithin() is always the same as firstChild().
  static ElementType* FirstWithin(const ContainerNode& current) { return FirstWithinTemplate(current); }
  static ElementType* FirstWithin(const Node& current) { return FirstWithinTemplate(current); }
  template <typename MatchFunc>
  static ElementType* FirstWithin(const ContainerNode&, MatchFunc);

  static ElementType* InclusiveFirstWithin(Node& current) {
    if (IsElementOfType<const ElementType>(current))
      return To<ElementType>(&current);
    return FirstWithin(current);
  }

  static ElementType* LastWithin(const ContainerNode& current) { return LastWithinTemplate(current); }
  static ElementType* LastWithin(const Node& current) { return LastWithinTemplate(current); }
  template <class MatchFunc>
  static ElementType* LastWithin(const ContainerNode&, MatchFunc);
  static ElementType* LastWithinOrSelf(ElementType&);

  // Pre-order traversal skipping non-element nodes.
  static ElementType* Next(const ContainerNode& current) { return NextTemplate(current); }
  static ElementType* Next(const Node& current) { return NextTemplate(current); }
  static ElementType* Next(const ContainerNode& current, const Node* stay_within) {
    return NextTemplate(current, stay_within);
  }
  static ElementType* Next(const Node& current, const Node* stay_within) { return NextTemplate(current, stay_within); }
  template <class MatchFunc>
  static ElementType* Next(const ContainerNode& current, const Node* stay_within, MatchFunc);
  static ElementType* Previous(const Node&);
  static ElementType* Previous(const Node&, const Node* stay_within);
  template <class MatchFunc>
  static ElementType* Previous(const ContainerNode& current, const Node* stay_within, MatchFunc);

  // Like next, but skips children.
  static ElementType* NextSkippingChildren(const Node&);
  static ElementType* NextSkippingChildren(const Node&, const Node* stay_within);
  // Previous / Next sibling.
  static ElementType* PreviousSibling(const Node&);
  template <class MatchFunc>
  static ElementType* PreviousSibling(const Node&, MatchFunc);
  static ElementType* NextSibling(const Node&);
  template <class MatchFunc>
  static ElementType* NextSibling(const Node&, MatchFunc);

  static TraversalSiblingRange<Traversal<ElementType>> ChildrenOf(const Node&);
  static TraversalDescendantRange<Traversal<ElementType>> DescendantsOf(const Node&);
  static TraversalInclusiveDescendantRange<Traversal<ElementType>> InclusiveDescendantsOf(const ElementType&);
  static TraversalNextRange<Traversal<ElementType>> StartsAt(const ElementType&);
  static TraversalNextRange<Traversal<ElementType>> StartsAfter(const Node&);

 private:
  template <class NodeType>
  static ElementType* FirstChildTemplate(NodeType&);
  template <class NodeType>
  static ElementType* LastChildTemplate(NodeType&);
  template <class NodeType>
  static ElementType* FirstAncestorOrSelfTemplate(NodeType&);
  template <class NodeType>
  static ElementType* FirstWithinTemplate(NodeType&);
  template <class NodeType>
  static ElementType* LastWithinTemplate(NodeType&);
  template <class NodeType>
  static ElementType* NextTemplate(NodeType&);
  template <class NodeType>
  static ElementType* NextTemplate(NodeType&, const Node* stay_within);
};

typedef Traversal<Element> ElementTraversal;

template <class ElementType>
inline TraversalSiblingRange<Traversal<ElementType>> Traversal<ElementType>::ChildrenOf(const Node& start) {
  return TraversalSiblingRange<Traversal<ElementType>>(Traversal<ElementType>::FirstChild(start));
}

template <class ElementType>
inline TraversalDescendantRange<Traversal<ElementType>> Traversal<ElementType>::DescendantsOf(const Node& root) {
  return TraversalDescendantRange<Traversal<ElementType>>(&root);
}

template <class ElementType>
inline TraversalInclusiveDescendantRange<Traversal<ElementType>> Traversal<ElementType>::InclusiveDescendantsOf(
    const ElementType& root) {
  return TraversalInclusiveDescendantRange<Traversal<ElementType>>(&root);
}

template <class ElementType>
inline TraversalNextRange<Traversal<ElementType>> Traversal<ElementType>::StartsAt(const ElementType& start) {
  return TraversalNextRange<Traversal<ElementType>>(&start);
}

template <class ElementType>
inline TraversalNextRange<Traversal<ElementType>> Traversal<ElementType>::StartsAfter(const Node& start) {
  return TraversalNextRange<Traversal<ElementType>>(Traversal<ElementType>::Next(start));
}

// Specialized for pure Element to exploit the fact that Elements parent is
// always either another Element or the root.
template <>
template <class NodeType>
inline Element* Traversal<Element>::FirstWithinTemplate(NodeType& current) {
  return FirstChildTemplate(current);
}

template <>
template <class NodeType>
inline Element* Traversal<Element>::NextTemplate(NodeType& current) {
  Node* node = NodeTraversal::Next(current);
  while (node && !node->IsElementNode())
    node = NodeTraversal::NextSkippingChildren(*node);
  return To<Element>(node);
}

template <>
template <class NodeType>
inline Element* Traversal<Element>::NextTemplate(NodeType& current, const Node* stay_within) {
  Node* node = NodeTraversal::Next(current, stay_within);
  while (node && !node->IsElementNode())
    node = NodeTraversal::NextSkippingChildren(*node, stay_within);
  return To<Element>(node);
}

// Generic versions.
template <class ElementType>
template <class NodeType>
inline ElementType* Traversal<ElementType>::FirstChildTemplate(NodeType& current) {
  Node* node = current.firstChild();
  while (node && !IsElementOfType<const ElementType>(*node))
    node = node->nextSibling();
  return To<ElementType>(node);
}

template <class ElementType>
template <class MatchFunc>
inline ElementType* Traversal<ElementType>::FirstChild(const ContainerNode& current, MatchFunc is_match) {
  ElementType* element = Traversal<ElementType>::FirstChild(current);
  while (element && !is_match(*element))
    element = Traversal<ElementType>::NextSibling(*element);
  return element;
}

template <class ElementType>
inline ElementType* Traversal<ElementType>::FirstAncestor(const Node& current) {
  ContainerNode* ancestor = current.parentNode();
  while (ancestor && !IsElementOfType<const ElementType>(*ancestor))
    ancestor = ancestor->parentNode();
  return To<ElementType>(ancestor);
}

template <class ElementType>
template <class NodeType>
inline ElementType* Traversal<ElementType>::FirstAncestorOrSelfTemplate(NodeType& current) {
  if (IsElementOfType<const ElementType>(current))
    return &To<ElementType>(current);
  return FirstAncestor(current);
}

template <class ElementType>
template <class NodeType>
inline ElementType* Traversal<ElementType>::LastChildTemplate(NodeType& current) {
  Node* node = current.lastChild();
  while (node && !IsElementOfType<const ElementType>(*node))
    node = node->previousSibling();
  return To<ElementType>(node);
}

template <class ElementType>
template <class MatchFunc>
inline ElementType* Traversal<ElementType>::LastChild(const ContainerNode& current, MatchFunc is_match) {
  ElementType* element = Traversal<ElementType>::LastChild(current);
  while (element && !is_match(*element))
    element = Traversal<ElementType>::PreviousSibling(*element);
  return element;
}

template <class ElementType>
template <class NodeType>
inline ElementType* Traversal<ElementType>::FirstWithinTemplate(NodeType& current) {
  Node* node = current.firstChild();
  while (node && !IsElementOfType<const ElementType>(*node))
    node = NodeTraversal::Next(*node, &current);
  return To<ElementType>(node);
}

template <class ElementType>
template <typename MatchFunc>
inline ElementType* Traversal<ElementType>::FirstWithin(const ContainerNode& current, MatchFunc is_match) {
  ElementType* element = Traversal<ElementType>::FirstWithin(current);
  while (element && !is_match(*element))
    element = Traversal<ElementType>::Next(*element, &current, is_match);
  return element;
}

template <class ElementType>
template <class NodeType>
inline ElementType* Traversal<ElementType>::LastWithinTemplate(NodeType& current) {
  Node* node = NodeTraversal::LastWithin(current);
  while (node && !IsElementOfType<const ElementType>(*node))
    node = NodeTraversal::Previous(*node, &current);
  return To<ElementType>(node);
}

template <class ElementType>
template <class MatchFunc>
inline ElementType* Traversal<ElementType>::LastWithin(const ContainerNode& current, MatchFunc is_match) {
  ElementType* element = Traversal<ElementType>::LastWithin(current);
  while (element && !is_match(*element))
    element = Traversal<ElementType>::Previous(*element, &current, is_match);
  return element;
}

template <class ElementType>
inline ElementType* Traversal<ElementType>::LastWithinOrSelf(ElementType& current) {
  if (ElementType* last_descendant = LastWithin(current))
    return last_descendant;
  return &current;
}

template <class ElementType>
template <class NodeType>
inline ElementType* Traversal<ElementType>::NextTemplate(NodeType& current) {
  Node* node = NodeTraversal::Next(current);
  while (node && !IsElementOfType<const ElementType>(*node))
    node = NodeTraversal::Next(*node);
  return To<ElementType>(node);
}

template <class ElementType>
template <class NodeType>
inline ElementType* Traversal<ElementType>::NextTemplate(NodeType& current, const Node* stay_within) {
  Node* node = NodeTraversal::Next(current, stay_within);
  while (node && !IsElementOfType<const ElementType>(*node))
    node = NodeTraversal::Next(*node, stay_within);
  return To<ElementType>(node);
}

template <class ElementType>
template <class MatchFunc>
inline ElementType* Traversal<ElementType>::Next(const ContainerNode& current,
                                                 const Node* stay_within,
                                                 MatchFunc is_match) {
  ElementType* element = Traversal<ElementType>::Next(current, stay_within);
  while (element && !is_match(*element))
    element = Traversal<ElementType>::Next(*element, stay_within);
  return element;
}

template <class ElementType>
inline ElementType* Traversal<ElementType>::Previous(const Node& current) {
  Node* node = NodeTraversal::Previous(current);
  while (node && !IsElementOfType<const ElementType>(*node))
    node = NodeTraversal::Previous(*node);
  return To<ElementType>(node);
}

template <class ElementType>
inline ElementType* Traversal<ElementType>::Previous(const Node& current, const Node* stay_within) {
  Node* node = NodeTraversal::Previous(current, stay_within);
  while (node && !IsElementOfType<const ElementType>(*node))
    node = NodeTraversal::Previous(*node, stay_within);
  return To<ElementType>(node);
}

template <class ElementType>
template <class MatchFunc>
inline ElementType* Traversal<ElementType>::Previous(const ContainerNode& current,
                                                     const Node* stay_within,
                                                     MatchFunc is_match) {
  ElementType* element = Traversal<ElementType>::Previous(current, stay_within);
  while (element && !is_match(*element))
    element = Traversal<ElementType>::Previous(*element, stay_within);
  return element;
}

template <class ElementType>
inline ElementType* Traversal<ElementType>::NextSkippingChildren(const Node& current) {
  Node* node = NodeTraversal::NextSkippingChildren(current);
  while (node && !IsElementOfType<const ElementType>(*node))
    node = NodeTraversal::NextSkippingChildren(*node);
  return To<ElementType>(node);
}

template <class ElementType>
inline ElementType* Traversal<ElementType>::NextSkippingChildren(const Node& current, const Node* stay_within) {
  Node* node = NodeTraversal::NextSkippingChildren(current, stay_within);
  while (node && !IsElementOfType<const ElementType>(*node))
    node = NodeTraversal::NextSkippingChildren(*node, stay_within);
  return To<ElementType>(node);
}

template <class ElementType>
inline ElementType* Traversal<ElementType>::PreviousSibling(const Node& current) {
  Node* node = current.previousSibling();
  while (node && !IsElementOfType<const ElementType>(*node))
    node = node->previousSibling();
  return To<ElementType>(node);
}

template <class ElementType>
template <class MatchFunc>
inline ElementType* Traversal<ElementType>::PreviousSibling(const Node& current, MatchFunc is_match) {
  ElementType* element = Traversal<ElementType>::PreviousSibling(current);
  while (element && !is_match(*element))
    element = Traversal<ElementType>::PreviousSibling(*element);
  return element;
}

template <class ElementType>
inline ElementType* Traversal<ElementType>::NextSibling(const Node& current) {
  Node* node = current.nextSibling();
  while (node && !IsElementOfType<const ElementType>(*node))
    node = node->nextSibling();
  return To<ElementType>(node);
}

template <class ElementType>
template <class MatchFunc>
inline ElementType* Traversal<ElementType>::NextSibling(const Node& current, MatchFunc is_match) {
  ElementType* element = Traversal<ElementType>::NextSibling(current);
  while (element && !is_match(*element))
    element = Traversal<ElementType>::NextSibling(*element);
  return element;
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_ELEMENT_TRAVERSAL_H_
