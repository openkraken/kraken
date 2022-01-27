/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "node.h"
#include "bindings/qjs/qjs_patch.h"
#include "comment_node.h"
#include "document.h"
#include "document_fragment.h"
#include "element.h"
#include "text_node.h"

namespace kraken {

void bindNode(std::unique_ptr<ExecutionContext>& context) {
  auto* contextData = context->contextData();
  JSValue constructor = Node::constructor(context.get());
  JSValue prototype = Node::prototype(context.get());

  // Install methods to Node.prototype.
  INSTALL_FUNCTION(Node, prototype, cloneNode, 1);
  INSTALL_FUNCTION(Node, prototype, appendChild, 1);
  INSTALL_FUNCTION(Node, prototype, remove, 0);
  INSTALL_FUNCTION(Node, prototype, removeChild, 1);
  INSTALL_FUNCTION(Node, prototype, insertBefore, 2);
  INSTALL_FUNCTION(Node, prototype, replaceChild, 2);

  context->defineGlobalProperty("Node", constructor);
}

JSValue Node::constructor(ExecutionContext* context) {
  return context->contextData()->constructorForType(&nodeTypeInfo);
}

JSValue Node::prototype(ExecutionContext* context) {
  return context->contextData()->prototypeForType(&nodeTypeInfo);
}

Node* Node::create(JSContext* ctx) {
  return nullptr;
}

JSClassID Node::classId{0};

IMPL_FUNCTION(Node, cloneNode)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto self = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));

  JSValue deepValue;
  if (argc < 1) {
    deepValue = JS_NewBool(ctx, false);
  } else {
    deepValue = argv[0];
  }

  if (!JS_IsBool(deepValue)) {
    return JS_ThrowTypeError(ctx, "Failed to cloneNode: deep should be a Boolean.");
  }
  bool deep = JS_ToBool(ctx, deepValue);

  if (self->nodeType == NodeType::ELEMENT_NODE) {
    JSValue newElementValue = copyNodeValue(ctx, self);
    auto* newElement = static_cast<Node*>(JS_GetOpaque(newElementValue, JSValueGetClassId(newElementValue)));

    if (deep) {
      traverseCloneNode(ctx, self, newElement);
    }
    return newElement->jsObject;
  } else if (self->nodeType == NodeType::TEXT_NODE) {
    auto textNode = static_cast<TextNode*>(self);
    JSValue newTextNode = copyNodeValue(ctx, static_cast<Node*>(textNode));
    return newTextNode;
  } else if (self->nodeType == NodeType::DOCUMENT_FRAGMENT_NODE) {
    JSValue newFragmentValue = JS_CallConstructor(ctx, DocumentFragment::constructor(self->context()), 0, nullptr);
    auto* newFragment = static_cast<Node*>(JS_GetOpaque(newFragmentValue, JSValueGetClassId(newFragmentValue)));

    if (deep) {
      traverseCloneNode(ctx, self, newFragment);
    }

    return newFragmentValue;
  }
  return JS_NULL;
}

IMPL_FUNCTION(Node, appendChild)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first argument is required.");
  }

  auto self = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  if (self == nullptr)
    return JS_ThrowTypeError(ctx, "this object is not a instance of Node.");
  JSValue nodeValue = argv[0];

  if (!JS_IsObject(nodeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.");
  }

  auto* node = static_cast<Node*>(JS_GetOpaque(nodeValue, JSValueGetClassId(nodeValue)));

  if (node == nullptr || node->ownerDocument() != self->ownerDocument()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.");
  }

  if (node == self) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': The new child element contains the parent.");
  }

  if (node->hasNodeFlag(Node::NodeFlag::IsDocumentFragment)) {
    size_t len = arrayGetLength(ctx, node->childNodes);
    for (int i = 0; i < len; i++) {
      JSValue n = JS_GetPropertyUint32(ctx, node->childNodes, i);
      self->internalAppendChild(static_cast<Node*>(JS_GetOpaque(n, JSValueGetClassId(n))));
      JS_FreeValue(ctx, n);
    }

    JS_SetPropertyStr(ctx, node->childNodes, "length", JS_NewUint32(ctx, 0));
  } else {
    self->ensureDetached(node);
    self->internalAppendChild(node);
  }

  return JS_DupValue(ctx, node->jsObject);
}
IMPL_FUNCTION(Node, remove)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto self = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  self->internalRemove();
  return JS_UNDEFINED;
}
IMPL_FUNCTION(Node, removeChild)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'removeChild' on 'Node': 1 arguments required");
  }

  JSValue nodeValue = argv[0];

  if (!JS_IsObject(nodeValue)) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'removeChild' on 'Node': 1st arguments is not object");
  }

  auto self = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  auto node = static_cast<Node*>(JS_GetOpaque(nodeValue, JSValueGetClassId(nodeValue)));

  if (node == nullptr || node->ownerDocument() != self->ownerDocument()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeChild' on 'Node': 1st arguments is not a Node object.");
  }

  auto removedNode = self->internalRemoveChild(node);
  return JS_DupValue(ctx, removedNode->jsObject);
}

IMPL_FUNCTION(Node, insertBefore)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'insertBefore' on 'Node': 2 arguments is required.");
  }

  JSValue nodeValue = argv[0];
  JSValue referenceNodeValue = argv[1];

  if (!JS_IsObject(nodeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'insertBefore' on 'Node': the node element is not object.");
  }

  Node* reference = nullptr;

  if (JS_IsObject(referenceNodeValue)) {
    reference = static_cast<Node*>(JS_GetOpaque(referenceNodeValue, JSValueGetClassId(referenceNodeValue)));
  } else if (!JS_IsNull(referenceNodeValue)) {
    return JS_ThrowTypeError(ctx, "TypeError: Failed to execute 'insertBefore' on 'Node': parameter 2 is not of type 'Node'");
  }

  auto self = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  auto node = static_cast<Node*>(JS_GetOpaque(nodeValue, JSValueGetClassId(nodeValue)));

  if (node == nullptr || node->ownerDocument() != self->ownerDocument()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'insertBefore' on 'Node': parameter 1 is not of type 'Node'");
  }

  if (node->hasNodeFlag(Node::NodeFlag::IsDocumentFragment)) {
    size_t len = arrayGetLength(ctx, node->childNodes);
    for (int i = 0; i < len; i++) {
      JSValue n = JS_GetPropertyUint32(ctx, node->childNodes, i);
      self->internalInsertBefore(static_cast<Node*>(JS_GetOpaque(n, JSValueGetClassId(n))), reference);
      JS_FreeValue(ctx, n);
    }

    // Clear fragment childNodes reference.
    JS_SetPropertyStr(ctx, node->childNodes, "length", JS_NewUint32(ctx, 0));
  } else {
    self->ensureDetached(node);
    self->internalInsertBefore(node, reference);
  }

  return JS_NULL;
}

IMPL_FUNCTION(Node, replaceChild)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 2 arguments required");
  }

  JSValue newChildValue = argv[0];
  JSValue oldChildValue = argv[1];

  if (!JS_IsObject(newChildValue)) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 1 arguments is not object");
  }

  if (!JS_IsObject(oldChildValue)) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 2 arguments is not object.");
  }

  auto self = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  auto newChild = static_cast<Node*>(JS_GetOpaque(newChildValue, JSValueGetClassId(newChildValue)));
  auto oldChild = static_cast<Node*>(JS_GetOpaque(oldChildValue, JSValueGetClassId(oldChildValue)));

  if (oldChild == nullptr || JS_VALUE_GET_PTR(oldChild->parentNode) != JS_VALUE_GET_PTR(self->jsObject) || oldChild->ownerDocument() != self->ownerDocument()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'replaceChild' on 'Node': The node to be replaced is not a child of this node.");
  }

  if (newChild == nullptr || newChild->ownerDocument() != self->ownerDocument()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'replaceChild' on 'Node': The new node is not a type of node.");
  }

  if (newChild->hasNodeFlag(Node::NodeFlag::IsDocumentFragment)) {
    size_t len = arrayGetLength(ctx, newChild->childNodes);
    for (int i = 0; i < len; i++) {
      JSValue n = JS_GetPropertyUint32(ctx, newChild->childNodes, i);
      auto* node = static_cast<Node*>(JS_GetOpaque(n, JSValueGetClassId(n)));
      self->internalInsertBefore(node, oldChild);
      JS_FreeValue(ctx, n);
    }
    self->internalRemoveChild(oldChild);
    // Clear fragment childNodes reference.
    JS_SetPropertyStr(ctx, newChild->childNodes, "length", JS_NewUint32(ctx, 0));
  } else {
    self->ensureDetached(newChild);
    self->internalReplaceChild(newChild, oldChild);
  }
  return JS_DupValue(ctx, oldChild->jsObject);
}

void Node::traverseCloneNode(JSContext* ctx, Node* baseNode, Node* targetNode) {
  int32_t len = arrayGetLength(ctx, baseNode->childNodes);
  for (int i = 0; i < len; i++) {
    JSValue n = JS_GetPropertyUint32(ctx, baseNode->childNodes, i);
    auto* node = static_cast<Node*>(JS_GetOpaque(n, JSValueGetClassId(n)));
    JSValue newNodeValue = copyNodeValue(ctx, node);
    auto newNode = static_cast<Node*>(JS_GetOpaque(newNodeValue, JSValueGetClassId(newNodeValue)));
    targetNode->ensureDetached(newNode);
    targetNode->internalAppendChild(newNode);
    // element node needs recursive child nodes.
    if (node->nodeType == NodeType::ELEMENT_NODE) {
      traverseCloneNode(ctx, node, newNode);
    }
    JS_FreeValue(ctx, newNodeValue);
    JS_FreeValue(ctx, n);
  }
}

JSValue Node::copyNodeValue(JSContext* ctx, Node* node) {
  if (node->nodeType == NodeType::ELEMENT_NODE) {
    auto* element = reinterpret_cast<Element*>(node);

    /* createElement */
    std::string tagName = element->getRegisteredTagName();
    JSValue tagNameValue = JS_NewString(element->ctx(), tagName.c_str());
    JSValue arguments[] = {tagNameValue};
    JSValue newElementValue = JS_CallConstructor(element->context()->ctx(), element->context()->contextData()->constructorForType(&elementTypeInfo), 1, arguments);
    JS_FreeValue(ctx, tagNameValue);

    auto* newElement = static_cast<Element*>(JS_GetOpaque(newElementValue, JSValueGetClassId(newElementValue)));

    /* copy attributes */
    newElement->m_attributes->copyWith(element->m_attributes);

    /* copy style */
    newElement->m_style->copyWith(element->m_style);

    /* copy properties */
    EventTarget::copyNodeProperties(newElement, element);

    std::string newNodeEventTargetId = std::to_string(newElement->eventTargetId());
    std::unique_ptr<NativeString> args_01 = stringToNativeString(newNodeEventTargetId);
    element->context()->uiCommandBuffer()->addCommand(element->eventTargetId(), UICommand::cloneNode, *args_01, nullptr);

    return newElement->jsObject;
  } else if (node->nodeType == TEXT_NODE) {
    auto* textNode = reinterpret_cast<Node*>(node);
    JSValue textContent = textNode->internalGetTextContent();
    JSValue arguments[] = {textContent};
    JSValue result = JS_CallConstructor(ctx, TextNode::constructor(textNode->context()), 1, arguments);
    JS_FreeValue(ctx, textContent);
    return result;
  }
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Node, isConnected)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* node = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  return JS_NewBool(ctx, node->isConnected());
}

IMPL_PROPERTY_GETTER(Node, ownerDocument)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* node = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  return JS_DupValue(ctx, node->ownerDocument()->jsObject);
}

IMPL_PROPERTY_GETTER(Node, firstChild)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* node = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  auto* instance = node->firstChild();
  return instance != nullptr ? instance->jsObject : JS_NULL;
}

IMPL_PROPERTY_GETTER(Node, lastChild)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* node = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  auto* instance = node->lastChild();
  return instance != nullptr ? instance->jsObject : JS_NULL;
}

IMPL_PROPERTY_GETTER(Node, parentNode)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* node = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  return JS_DupValue(ctx, node->parentNode);
}

IMPL_PROPERTY_GETTER(Node, previousSibling)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* node = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  auto* instance = node->previousSibling();
  return instance != nullptr ? instance->jsObject : JS_NULL;
}

IMPL_PROPERTY_GETTER(Node, nextSibling)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* node = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  auto* instance = node->nextSibling();
  return instance != nullptr ? instance->jsObject : JS_NULL;
}

IMPL_PROPERTY_GETTER(Node, nodeType)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* node = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  return JS_NewUint32(ctx, node->nodeType);
}

IMPL_PROPERTY_GETTER(Node, textContent)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* node = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  return node->internalGetTextContent();
}
IMPL_PROPERTY_SETTER(Node, textContent)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* node = static_cast<Node*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  node->internalSetTextContent(argv[0]);
  return JS_NULL;
}

bool Node::isConnected() {
  bool _isConnected = this == ownerDocument();
  auto parent = static_cast<Node*>(JS_GetOpaque(parentNode, JSValueGetClassId(parentNode)));

  while (parent != nullptr && !_isConnected) {
    _isConnected = parent == ownerDocument();
    JSValue parentParentNode = parent->parentNode;
    parent = static_cast<Node*>(JS_GetOpaque(parentParentNode, JSValueGetClassId(parentParentNode)));
  }

  return _isConnected;
}
Document* Node::ownerDocument() {
  if (nodeType == NodeType::DOCUMENT_NODE) {
    return nullptr;
  }

  return context()->document();
}
Node* Node::firstChild() {
  int32_t len = arrayGetLength(m_ctx, childNodes);
  if (len == 0) {
    return nullptr;
  }
  JSValue result = JS_GetPropertyUint32(m_ctx, childNodes, 0);
  return static_cast<Node*>(JS_GetOpaque(result, JSValueGetClassId(result)));
}
Node* Node::lastChild() {
  int32_t len = arrayGetLength(m_ctx, childNodes);
  if (len == 0) {
    return nullptr;
  }
  JSValue result = JS_GetPropertyUint32(m_ctx, childNodes, len - 1);
  return static_cast<Node*>(JS_GetOpaque(result, JSValueGetClassId(result)));
}
Node* Node::previousSibling() {
  if (JS_IsNull(parentNode))
    return nullptr;

  auto* parent = static_cast<Node*>(JS_GetOpaque(parentNode, JSValueGetClassId(parentNode)));
  auto parentChildNodes = parent->childNodes;
  int32_t idx = arrayFindIdx(m_ctx, parentChildNodes, jsObject);
  int32_t parentChildNodeLen = arrayGetLength(m_ctx, parentChildNodes);

  if (idx - 1 < parentChildNodeLen) {
    JSValue result = JS_GetPropertyUint32(m_ctx, parentChildNodes, idx - 1);
    return static_cast<Node*>(JS_GetOpaque(result, JSValueGetClassId(result)));
  }

  return nullptr;
}
Node* Node::nextSibling() {
  if (JS_IsNull(parentNode))
    return nullptr;
  auto* parent = static_cast<Node*>(JS_GetOpaque(parentNode, JSValueGetClassId(parentNode)));
  auto parentChildNodes = parent->childNodes;
  int32_t idx = arrayFindIdx(m_ctx, parentChildNodes, jsObject);
  int32_t parentChildNodeLen = arrayGetLength(m_ctx, parentChildNodes);

  if (idx + 1 < parentChildNodeLen) {
    JSValue result = JS_GetPropertyUint32(m_ctx, parentChildNodes, idx + 1);
    return static_cast<Node*>(JS_GetOpaque(result, JSValueGetClassId(result)));
  }

  return nullptr;
}
void Node::internalAppendChild(Node* node) {
  arrayPushValue(m_ctx, childNodes, node->jsObject);
  node->setParentNode(this);

  node->_notifyNodeInsert(this);

  std::string nodeEventTargetId = std::to_string(node->eventTargetId());
  std::string position = std::string("beforeend");

  std::unique_ptr<NativeString> args_01 = stringToNativeString(nodeEventTargetId);
  std::unique_ptr<NativeString> args_02 = stringToNativeString(position);

  context()->uiCommandBuffer()->addCommand(eventTargetId(), UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);
}
void Node::internalRemove() {
  if (JS_IsNull(parentNode))
    return;
  auto* parent = static_cast<Node*>(JS_GetOpaque(parentNode, JSValueGetClassId(parentNode)));
  parent->internalRemoveChild(this);
}
void Node::internalClearChild() {
  int32_t len = arrayGetLength(m_ctx, childNodes);

  for (int i = 0; i < len; i++) {
    JSValue v = JS_GetPropertyUint32(m_ctx, childNodes, i);
    auto* node = static_cast<Node*>(JS_GetOpaque(v, JSValueGetClassId(v)));
    node->removeParentNode();
    node->_notifyNodeRemoved(this);
    node->context()->uiCommandBuffer()->addCommand(node->eventTargetId(), UICommand::removeNode, nullptr);
    JS_FreeValue(m_ctx, v);
  }

  JS_SetPropertyStr(m_ctx, childNodes, "length", JS_NewUint32(m_ctx, 0));
}
Node* Node::internalRemoveChild(Node* node) {
  int32_t idx = arrayFindIdx(m_ctx, childNodes, node->jsObject);

  if (idx != -1) {
    arraySpliceValue(m_ctx, childNodes, idx, 1);
    node->removeParentNode();
    node->_notifyNodeRemoved(this);
    node->context()->uiCommandBuffer()->addCommand(node->eventTargetId(), UICommand::removeNode, nullptr);
  }

  return node;
}
JSValue Node::internalInsertBefore(Node* node, Node* referenceNode) {
  if (referenceNode == nullptr) {
    internalAppendChild(node);
  } else {
    if (JS_VALUE_GET_PTR(referenceNode->parentNode) != JS_VALUE_GET_PTR(jsObject)) {
      return JS_ThrowTypeError(m_ctx, "Uncaught TypeError: Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.");
    }

    auto parentNodeValue = referenceNode->parentNode;
    auto* parent = static_cast<Node*>(JS_GetOpaque(parentNodeValue, JSValueGetClassId(parentNodeValue)));
    if (parent != nullptr) {
      JSValue parentChildNodes = parent->childNodes;
      int32_t idx = arrayFindIdx(m_ctx, parentChildNodes, referenceNode->jsObject);

      if (idx == -1) {
        return JS_ThrowTypeError(m_ctx, "Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.");
      }

      arrayInsert(m_ctx, parentChildNodes, idx, node->jsObject);
      node->setParentNode(parent);
      node->_notifyNodeInsert(parent);

      std::string nodeEventTargetId = std::to_string(node->eventTargetId());
      std::string position = std::string("beforebegin");

      std::unique_ptr<NativeString> args_01 = stringToNativeString(nodeEventTargetId);
      std::unique_ptr<NativeString> args_02 = stringToNativeString(position);

      context()->uiCommandBuffer()->addCommand(referenceNode->eventTargetId(), UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);
    }
  }

  return JS_NULL;
}
JSValue Node::internalGetTextContent() {
  return JS_NULL;
}
void Node::internalSetTextContent(JSValue content) {}
JSValue Node::internalReplaceChild(Node* newChild, Node* oldChild) {
  assert_m(JS_IsNull(newChild->parentNode), "ReplaceChild Error: newChild was not detached.");
  oldChild->removeParentNode();

  int32_t childIndex = arrayFindIdx(m_ctx, childNodes, oldChild->jsObject);
  if (childIndex == -1) {
    return JS_ThrowTypeError(m_ctx, "Failed to execute 'replaceChild' on 'Node': old child is not exist on childNodes.");
  }

  newChild->setParentNode(this);

  arraySpliceValue(m_ctx, childNodes, childIndex, 1, newChild->jsObject);

  oldChild->_notifyNodeRemoved(this);
  newChild->_notifyNodeInsert(this);

  std::string newChildEventTargetId = std::to_string(newChild->eventTargetId());
  std::string position = std::string("afterend");

  std::unique_ptr<NativeString> args_01 = stringToNativeString(newChildEventTargetId);
  std::unique_ptr<NativeString> args_02 = stringToNativeString(position);

  context()->uiCommandBuffer()->addCommand(oldChild->eventTargetId(), UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);

  context()->uiCommandBuffer()->addCommand(oldChild->eventTargetId(), UICommand::removeNode, nullptr);

  return oldChild->jsObject;
}

void Node::setParentNode(Node* parent) {
  if (!JS_IsNull(parentNode)) {
    JS_FreeValue(m_ctx, parentNode);
  }

  parentNode = JS_DupValue(m_ctx, parent->jsObject);
}

void Node::removeParentNode() {
  if (!JS_IsNull(parentNode)) {
    JS_FreeValue(m_ctx, parentNode);
  }

  parentNode = JS_NULL;
}

void Node::refer() {
  JS_DupValue(m_ctx, jsObject);
  list_add_tail(&nodeLink.link, &context()->node_job_list);
}
void Node::unrefer() {
  list_del(&nodeLink.link);
  JS_FreeValue(m_ctx, jsObject);
}
void Node::_notifyNodeRemoved(Node* node) {}
void Node::_notifyNodeInsert(Node* node) {}
void Node::ensureDetached(Node* node) {
  auto* nodeParent = static_cast<Node*>(JS_GetOpaque(node->parentNode, JSValueGetClassId(node->parentNode)));

  if (nodeParent != nullptr) {
    int32_t idx = arrayFindIdx(m_ctx, nodeParent->childNodes, node->jsObject);
    if (idx != -1) {
      node->_notifyNodeRemoved(nodeParent);
      arraySpliceValue(m_ctx, nodeParent->childNodes, idx, 1);
      node->removeParentNode();
    }
  }
}

void Node::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  EventTarget::trace(rt, val, mark_func);

  // Should check object is already inited before gc mark.
  if (JS_IsObject(parentNode))
    JS_MarkValue(rt, parentNode, mark_func);
}

void Node::dispose() const {}

}  // namespace kraken
