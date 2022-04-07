/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "node.h"
#include "child_node_list.h"
#include "document.h"
#include "document_fragment.h"
#include "empty_node_list.h"
#include "node_data.h"
#include "node_list.h"
#include "attr.h"

namespace kraken {

Node* Node::Create(ExecutingContext* context, ExceptionState& exception_state) {
  exception_state.ThrowException(context->ctx(), ErrorType::TypeError, "Illegal constructor");
}

ContainerNode* Node::parentNode() const {
  return ParentOrShadowHostNode();
}

NodeList* Node::childNodes() {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node)
    return EnsureData().EnsureChildNodeList(*this_node);
  return EnsureData().EnsureEmptyChildNodeList(*this);
}

NodeData& Node::CreateData() {
  data_ = std::make_unique<NodeData>();
  return *Data();
}

NodeData& Node::EnsureData() {
  if (HasData())
    return *Data();
  return CreateData();
}

Node& Node::TreeRoot() const {
  const Node* node = this;
  while (node->parentNode())
    node = node->parentNode();
  return const_cast<Node&>(*node);
}

void Node::remove(ExceptionState& exception_state) {
  if (ContainerNode* parent = parentNode())
    parent->RemoveChild(this, exception_state);
}

Node* Node::insertBefore(Node* new_child, Node* ref_child, ExceptionState& exception_state) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node)
    return this_node->InsertBefore(new_child, ref_child, exception_state);

  exception_state.ThrowException(ctx(), ErrorType::TypeError, "This node type does not support this method.");
  return nullptr;
}

Node* Node::replaceChild(Node* new_child, Node* old_child, ExceptionState& exception_state) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node)
    return this_node->ReplaceChild(new_child, old_child, exception_state);

  exception_state.ThrowException(ctx(), ErrorType::TypeError, "This node type does not support this method.");
  return nullptr;
}

Node* Node::removeChild(Node* old_child, ExceptionState& exception_state) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node)
    return this_node->RemoveChild(old_child, exception_state);

  exception_state.ThrowException(ctx(), ErrorType::TypeError, "This node type does not support this method.");
  return nullptr;
}

Node* Node::appendChild(Node* new_child, ExceptionState& exception_state) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node)
    return this_node->AppendChild(new_child, exception_state);

  exception_state.ThrowException(ctx(), ErrorType::TypeError, "This node type does not support this method.");
  return nullptr;
}

Node* Node::cloneNode(bool deep, ExceptionState&) const {
  // https://dom.spec.whatwg.org/#dom-node-clonenode

  // 2. Return a clone of this, with the clone children flag set if deep is
  // true, and the clone shadows flag set if this is a DocumentFragment whose
  // host is an HTML template element.
  auto* fragment = DynamicTo<DocumentFragment>(this);
  bool clone_shadows_flag = fragment && fragment->IsTemplateContent();
  return Clone(GetDocument(),
               deep ? (clone_shadows_flag ? CloneChildrenFlag::kCloneWithShadows : CloneChildrenFlag::kClone)
                    : CloneChildrenFlag::kSkip);
}

bool Node::isEqualNode(Node* other) const {
  if (!other)
    return false;

  NodeType node_type = getNodeType();
  if (node_type != other->getNodeType())
    return false;

  if (nodeValue() != other->nodeValue())
    return false;

  if (auto* this_attr = DynamicTo<Attr>(this)) {
    auto* other_attr = To<Attr>(other);
    if (this_attr->localName() != other_attr->localName())
      return false;

    if (this_attr->namespaceURI() != other_attr->namespaceURI())
      return false;
  } else if (auto* this_element = DynamicTo<Element>(this)) {
    auto* other_element = DynamicTo<Element>(other);
    if (this_element->TagQName() != other_element->TagQName())
      return false;

    if (!this_element->HasEquivalentAttributes(*other_element))
      return false;
  } else if (nodeName() != other->nodeName()) {
    return false;
  }

  Node* child = firstChild();
  Node* other_child = other->firstChild();

  while (child) {
    if (!child->isEqualNode(other_child))
      return false;

    child = child->nextSibling();
    other_child = other_child->nextSibling();
  }

  if (other_child)
    return false;

  if (const auto* document_type_this = DynamicTo<DocumentType>(this)) {
    const auto* document_type_other = To<DocumentType>(other);

    if (document_type_this->publicId() != document_type_other->publicId())
      return false;

    if (document_type_this->systemId() != document_type_other->systemId())
      return false;
  }

  return true;
}

Node::Node(Document* document, ConstructionType type)
    : EventTarget(document->GetExecutingContext()),
      node_flags_(type),
      parent_or_shadow_host_node_(nullptr),
      previous_(nullptr),
      next_(nullptr) {
}

void Node::Trace(GCVisitor*) const {}

}  // namespace kraken
