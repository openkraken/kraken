/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "node.h"
#include "character_data.h"
#include "child_node_list.h"
#include "document.h"
#include "document_fragment.h"
#include "empty_node_list.h"
#include "node_data.h"
#include "node_list.h"
#include "node_traversal.h"
#include "template_content_document_fragment.h"
#include "text.h"

namespace kraken {

Node* Node::Create(ExecutingContext* context, ExceptionState& exception_state) {
  exception_state.ThrowException(context->ctx(), ErrorType::TypeError, "Illegal constructor");
}

void Node::setNodeValue(const AtomicString& value, ExceptionState& exception_state) {
  // By default, setting nodeValue has no effect.
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

Node* Node::cloneNode(ExceptionState& exception_state) const {
  return cloneNode(false, exception_state);
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

bool Node::isEqualNode(Node* other, ExceptionState& exception_state) const {
  if (!other)
    return false;

  NodeType node_type = nodeType();
  if (node_type != other->nodeType())
    return false;

  if (nodeValue() != other->nodeValue())
    return false;

//  if (auto* this_attr = DynamicTo<Attr>(this)) {
//    auto* other_attr = To<Attr>(other);
//    if (this_attr->localName() != other_attr->localName())
//      return false;
//
//    if (this_attr->namespaceURI() != other_attr->namespaceURI())
//      return false;
//  } else


  if (auto* this_element = DynamicTo<Element>(this)) {
    auto* other_element = DynamicTo<Element>(other);
    if (this_element->tagName() != other_element->tagName())
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

  return true;
}

bool Node::isEqualNode(Node* other) const {
  ExceptionState exception_state;
  return isEqualNode(other, exception_state);
}

AtomicString Node::textContent(bool convert_brs_to_newlines) const {
  // This covers ProcessingInstruction and Comment that should return their
  // value when .textContent is accessed on them, but should be ignored when
  // iterated over as a descendant of a ContainerNode.
  if (auto* character_data = DynamicTo<CharacterData>(this))
    return character_data->data();

  // Attribute nodes have their attribute values as textContent.
//  if (auto* attr = DynamicTo<Attr>(this))
//    return attr->value();

  // Documents and non-container nodes (that are not CharacterData)
  // have null textContent.
  if (IsDocumentNode() || !IsContainerNode())
    return AtomicString::Empty(ctx());

  std::string content;
  for (const Node& node : NodeTraversal::InclusiveDescendantsOf(*this)) {
    if (auto* text_node = DynamicTo<Text>(node)) {
      content.append(text_node->data().ToStdString());
    }
  }
  return AtomicString(ctx(), content);
}

void Node::setTextContent(const AtomicString& text, ExceptionState& exception_state) {
  switch (nodeType()) {
    case kAttributeNode:
    case kTextNode:
    case kCommentNode:
      setNodeValue(text, exception_state);
      return;
    case kElementNode:
    case kDocumentFragmentNode: {
      // FIXME: Merge this logic into replaceChildrenWithText.
      auto* container = To<ContainerNode>(this);

      // Note: This is an intentional optimization.
      // See crbug.com/352836 also.
      // No need to do anything if the text is identical.
      if (container->HasOneTextChild() && To<Text>(container->firstChild())->data() == text && !text.IsEmpty())
        return;

      // Note: This API will not insert empty text nodes:
      // https://dom.spec.whatwg.org/#dom-node-textcontent
      if (text.IsEmpty()) {
        container->RemoveChildren();
      } else {
        container->RemoveChildren();
        container->AppendChild(GetDocument().createTextNode(text), exception_state);
      }
      return;
    }
    case kDocumentNode:
    case kDocumentTypeNode:
      // Do nothing.
      return;
  }
}

void Node::SetCustomElementState(CustomElementState new_state) {
  CustomElementState old_state = GetCustomElementState();

  switch (new_state) {
    case CustomElementState::kUncustomized:
      return;

    case CustomElementState::kUndefined:
      assert(CustomElementState::kUncustomized == old_state);
      break;

    case CustomElementState::kCustom:
      assert(old_state == CustomElementState::kUndefined || old_state == CustomElementState::kFailed ||
             old_state == CustomElementState::kPreCustomized);
      break;

    case CustomElementState::kFailed:
      assert(CustomElementState::kFailed != old_state);
      break;

    case CustomElementState::kPreCustomized:
      assert(CustomElementState::kFailed == old_state);
      break;
  }

  assert(IsHTMLElement());

  auto* element = To<Element>(this);
  node_flags_ = (node_flags_ & ~kCustomElementStateMask) | static_cast<NodeFlags>(new_state);
  assert(new_state == GetCustomElementState());
}

bool Node::IsDocumentNode() const {
  return this == &GetDocument();
}

Element* Node::ParentOrShadowHostElement() const {
  ContainerNode* parent = ParentOrShadowHostNode();
  if (!parent)
    return nullptr;

  return DynamicTo<Element>(parent);
}

void Node::InsertedInto(ContainerNode& insertion_point) {
  assert(insertion_point.isConnected() || IsContainerNode());
  if (insertion_point.isConnected()) {
    SetFlag(kIsConnectedFlag);
    insertion_point.GetDocument().IncrementNodeCount();
  }
}

void Node::RemovedFrom(ContainerNode& insertion_point) {
  assert(insertion_point.isConnected() || IsContainerNode());
  if (insertion_point.isConnected()) {
    ClearFlag(kIsConnectedFlag);
    insertion_point.GetDocument().DecrementNodeCount();
  }
}

ContainerNode* Node::ParentOrShadowHostOrTemplateHostNode() const {
  auto* this_fragment = DynamicTo<DocumentFragment>(this);
  if (this_fragment && this_fragment->IsTemplateContent())
    return static_cast<const TemplateContentDocumentFragment*>(this)->Host();
  return ParentOrShadowHostNode();
}

ContainerNode* Node::NonShadowBoundaryParentNode() const {
  return parentNode();
}

unsigned int Node::NodeIndex() const {
  const Node* temp_node = previousSibling();
  unsigned count = 0;
  for (count = 0; temp_node; count++)
    temp_node = temp_node->previousSibling();
  return count;
}

Document* Node::ownerDocument() const {
  Document* doc = &GetDocument();
  return doc == this ? nullptr : doc;
}

bool Node::IsDescendantOf(const Node* other) const {
  // Return true if other is an ancestor of this, otherwise false
  if (!other || isConnected() != other->isConnected())
    return false;
  if (&other->GetDocument() != &GetDocument())
    return false;
  for (const ContainerNode* n = parentNode(); n; n = n->parentNode()) {
    if (n == other)
      return true;
  }
  return false;
}

bool Node::contains(const Node* node, ExceptionState& exception_state) const {
  if (!node)
    return false;
  return this == node || node->IsDescendantOf(this);
}

bool Node::ContainsIncludingHostElements(const Node& node) const {
  const Node* current = &node;
  do {
    if (current == this)
      return true;
    auto* curr_fragment = DynamicTo<DocumentFragment>(current);
    if (curr_fragment && curr_fragment->IsTemplateContent())
      current = static_cast<const TemplateContentDocumentFragment*>(current)->Host();
    else
      current = current->ParentOrShadowHostNode();
  } while (current);
  return false;
}

Node* Node::CommonAncestor(const Node& other, ContainerNode* (*parent)(const Node&)) const {
  if (this == &other)
    return const_cast<Node*>(this);
  if (&GetDocument() != &other.GetDocument())
    return nullptr;
  int this_depth = 0;
  for (const Node* node = this; node; node = parent(*node)) {
    if (node == &other)
      return const_cast<Node*>(node);
    this_depth++;
  }
  int other_depth = 0;
  for (const Node* node = &other; node; node = parent(*node)) {
    if (node == this)
      return const_cast<Node*>(this);
    other_depth++;
  }
  const Node* this_iterator = this;
  const Node* other_iterator = &other;
  if (this_depth > other_depth) {
    for (int i = this_depth; i > other_depth; --i)
      this_iterator = parent(*this_iterator);
  } else if (other_depth > this_depth) {
    for (int i = other_depth; i > this_depth; --i)
      other_iterator = parent(*other_iterator);
  }
  while (this_iterator) {
    if (this_iterator == other_iterator)
      return const_cast<Node*>(this_iterator);
    this_iterator = parent(*this_iterator);
    other_iterator = parent(*other_iterator);
  }
  assert(!other_iterator);
  return nullptr;
}

Node::Node(Document* document, ConstructionType type)
    : EventTarget(document->GetExecutingContext()),
      node_flags_(type),
      parent_or_shadow_host_node_(nullptr),
      previous_(nullptr),
      next_(nullptr) {}

void Node::Trace(GCVisitor*) const {}

}  // namespace kraken
