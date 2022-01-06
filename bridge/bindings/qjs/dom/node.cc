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
#include "kraken_bridge.h"
#include "node_list.h"
#include "text_node.h"

namespace kraken::binding::qjs {

void bindNode(std::unique_ptr<ExecutionContext>& context) {
  auto* constructor = Node::instance(context.get());
  context->defineGlobalProperty("Node", constructor->jsObject);
}

JSValue Node::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}

JSClassID Node::classId() {
  assert_m(false, "classId is not implemented");
  return 0;
}

JSClassID Node::classId(JSValue& value) {
  JSClassID classId = JSValueGetClassId(value);
  if (classId == Element::classId() || classId == Document::classId() || classId == TextNode::classId() || classId == Comment::classId() || classId == DocumentFragment::classId()) {
    return classId;
  }

  return 0;
}

JSValue Node::cloneNode(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto selfInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));

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

  if (selfInstance->isElementNode()) {
    JSValue newElement = copyNodeValue(ctx, selfInstance);
    auto newElementInstance = static_cast<NodeInstance*>(JS_GetOpaque(newElement, Node::classId(newElement)));

    if (deep) {
      traverseCloneNode(ctx, selfInstance, newElementInstance);
    }
    return newElementInstance->jsObject;
  } else if (selfInstance->isTextNode()) {
    auto textNode = static_cast<TextNodeInstance*>(selfInstance);
    JSValue newTextNode = copyNodeValue(ctx, static_cast<NodeInstance*>(textNode));
    return newTextNode;
  } else if (selfInstance->isDocumentFragment()) {
    JSValue newFragment = JS_CallConstructor(ctx, DocumentFragment::instance(selfInstance->m_context)->jsObject, 0, nullptr);
    auto* newFragmentInstance = static_cast<NodeInstance*>(JS_GetOpaque(newFragment, Node::classId(newFragment)));

    if (deep) {
      traverseCloneNode(ctx, selfInstance, newFragmentInstance);
    }

    return newFragment;
  }
  return JS_NULL;
}

JSValue Node::appendChild(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first argument is required.");
  }

  auto self = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  if (self == nullptr)
    return JS_ThrowTypeError(ctx, "this object is not a instance of Node.");
  JSValue nodeValue = argv[0];

  if (!JS_IsObject(nodeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.");
  }

  auto* newNode = static_cast<NodeInstance*>(JS_GetOpaque(nodeValue, Node::classId(nodeValue)));

  if (newNode == nullptr || newNode->document() != self->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.");
  }

  if (newNode == self) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': The new child element contains the parent.");
  }

  if (!self->getFlag(NodeInstance::kIsConnectedFlag)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': This node type does not support this method.");
  }

  JSValue exception = JS_NULL;
  NodeInstance* returnNode = self->internalAppendChild(newNode, &exception);

  if (JS_IsException(exception)) {
    return exception;
  }
  return JS_DupValue(ctx, returnNode->jsObject);
}
JSValue Node::remove(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto selfInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  selfInstance->internalRemove();
  return JS_UNDEFINED;
}
JSValue Node::removeChild(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'removeChild' on 'Node': 1 arguments required");
  }

  JSValue nodeValue = argv[0];

  if (!JS_IsObject(nodeValue)) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'removeChild' on 'Node': 1st arguments is not object");
  }

  auto selfInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(nodeValue, Node::classId(nodeValue)));

  if (nodeInstance == nullptr || nodeInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeChild' on 'Node': 1st arguments is not a Node object.");
  }

  auto removedNode = selfInstance->internalRemoveChild(nodeInstance);
  return JS_DupValue(ctx, removedNode->jsObject);
}

JSValue Node::insertBefore(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'insertBefore' on 'Node': 2 arguments is required.");
  }

  JSValue nodeValue = argv[0];
  JSValue referenceNodeValue = argv[1];

  if (!JS_IsObject(nodeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'insertBefore' on 'Node': the node element is not object.");
  }

  NodeInstance* referenceInstance = nullptr;

  if (JS_IsObject(referenceNodeValue)) {
    referenceInstance = static_cast<NodeInstance*>(JS_GetOpaque(referenceNodeValue, Node::classId(referenceNodeValue)));
  } else if (!JS_IsNull(referenceNodeValue)) {
    return JS_ThrowTypeError(ctx, "TypeError: Failed to execute 'insertBefore' on 'Node': parameter 2 is not of type 'Node'");
  }

  auto selfInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(nodeValue, Node::classId(nodeValue)));

  if (nodeInstance == nullptr || nodeInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'insertBefore' on 'Node': parameter 1 is not of type 'Node'");
  }

  if (nodeInstance->hasNodeFlag(NodeInstance::NodeFlag::IsDocumentFragmentFlag)) {
    size_t len = arrayGetLength(ctx, nodeInstance->childNodes);
    for (int i = 0; i < len; i++) {
      JSValue n = JS_GetPropertyUint32(ctx, nodeInstance->childNodes, i);
      auto* node = static_cast<NodeInstance*>(JS_GetOpaque(n, Node::classId(n)));
      selfInstance->internalInsertBefore(node, referenceInstance);
      JS_FreeValue(ctx, n);
    }

    // Clear fragment childNodes reference.
    JS_SetPropertyStr(ctx, nodeInstance->childNodes, "length", JS_NewUint32(ctx, 0));
  } else {
    selfInstance->ensureDetached(nodeInstance);
    selfInstance->internalInsertBefore(nodeInstance, referenceInstance);
  }

  return JS_NULL;
}

JSValue Node::replaceChild(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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

  auto selfInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto newChildInstance = static_cast<NodeInstance*>(JS_GetOpaque(newChildValue, Node::classId(newChildValue)));
  auto oldChildInstance = static_cast<NodeInstance*>(JS_GetOpaque(oldChildValue, Node::classId(oldChildValue)));

  if (oldChildInstance == nullptr || JS_VALUE_GET_PTR(oldChildInstance->parentNode) != JS_VALUE_GET_PTR(selfInstance->jsObject) || oldChildInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'replaceChild' on 'Node': The node to be replaced is not a child of this node.");
  }

  if (newChildInstance == nullptr || newChildInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'replaceChild' on 'Node': The new node is not a type of node.");
  }

  if (newChildInstance->hasNodeFlag(NodeInstance::NodeFlag::IsDocumentFragmentFlag)) {
    size_t len = arrayGetLength(ctx, newChildInstance->childNodes);
    for (int i = 0; i < len; i++) {
      JSValue n = JS_GetPropertyUint32(ctx, newChildInstance->childNodes, i);
      auto* node = static_cast<NodeInstance*>(JS_GetOpaque(n, Node::classId(n)));
      selfInstance->internalInsertBefore(node, oldChildInstance);
      JS_FreeValue(ctx, n);
    }
    selfInstance->internalRemoveChild(oldChildInstance);
    // Clear fragment childNodes reference.
    JS_SetPropertyStr(ctx, newChildInstance->childNodes, "length", JS_NewUint32(ctx, 0));
  } else {
    selfInstance->ensureDetached(newChildInstance);
    selfInstance->internalReplaceChild(newChildInstance, oldChildInstance);
  }
  return JS_DupValue(ctx, oldChildInstance->jsObject);
}

void Node::traverseCloneNode(JSContext* ctx, NodeInstance* baseNode, NodeInstance* targetNode) {
  int32_t len = arrayGetLength(ctx, baseNode->childNodes);
  for (int i = 0; i < len; i++) {
    JSValue n = JS_GetPropertyUint32(ctx, baseNode->childNodes, i);
    auto* node = static_cast<NodeInstance*>(JS_GetOpaque(n, Node::classId(n)));
    JSValue newNode = copyNodeValue(ctx, node);
    auto newNodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(newNode, Node::classId(newNode)));
    targetNode->ensureDetached(newNodeInstance);
    targetNode->internalAppendChild(newNodeInstance);
    // element node needs recursive child nodes.
    if (node->isElementNode()) {
      traverseCloneNode(ctx, node, newNodeInstance);
    }
    JS_FreeValue(ctx, newNode);
    JS_FreeValue(ctx, n);
  }
}

JSValue Node::copyNodeValue(JSContext* ctx, NodeInstance* node) {
  if (node->isElementNode()) {
    auto* element = reinterpret_cast<ElementInstance*>(node);

    /* createElement */
    std::string tagName = element->getRegisteredTagName();
    JSValue tagNameValue = JS_NewString(element->m_ctx, tagName.c_str());
    JSValue arguments[] = {tagNameValue};
    JSValue newElementValue = JS_CallConstructor(element->context()->ctx(), Element::instance(element->context())->jsObject, 1, arguments);
    JS_FreeValue(ctx, tagNameValue);

    auto* newElement = static_cast<ElementInstance*>(JS_GetOpaque(newElementValue, Node::classId(newElementValue)));

    /* copy attributes */
    newElement->m_attributes->copyWith(element->m_attributes);

    /* copy style */
    newElement->m_style->copyWith(element->m_style);

    /* copy properties */
    ElementInstance::copyNodeProperties(newElement, element);

    std::string newNodeEventTargetId = std::to_string(newElement->m_eventTargetId);
    std::unique_ptr<NativeString> args_01 = stringToNativeString(newNodeEventTargetId);
    element->m_context->uiCommandBuffer()->addCommand(element->m_eventTargetId, UICommand::cloneNode, *args_01, nullptr);

    return newElement->jsObject;
  } else if (node->isTextNode()) {
    auto* textNode = reinterpret_cast<TextNodeInstance*>(node);
    JSValue textContent = textNode->internalGetTextContent();
    JSValue arguments[] = {textContent};
    JSValue result = JS_CallConstructor(ctx, TextNode::instance(textNode->m_context)->jsObject, 1, arguments);
    JS_FreeValue(ctx, textContent);
    return result;
  }
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Node, isConnected)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return JS_NewBool(ctx, nodeInstance->isConnected());
}

IMPL_PROPERTY_GETTER(Node, ownerDocument)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return JS_DupValue(ctx, nodeInstance->m_document->jsObject);
}

IMPL_PROPERTY_GETTER(Node, firstChild)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto* instance = nodeInstance->firstChild();
  return instance != nullptr ? instance->jsObject : JS_NULL;
}

IMPL_PROPERTY_GETTER(Node, lastChild)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto* instance = nodeInstance->lastChild();
  return instance != nullptr ? instance->jsObject : JS_NULL;
}

IMPL_PROPERTY_GETTER(Node, parentNode)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return JS_DupValue(ctx, nodeInstance->parentNode);
}

IMPL_PROPERTY_GETTER(Node, previousSibling)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto* instance = nodeInstance->previousSibling();
  return instance != nullptr ? instance->jsObject : JS_NULL;
}

IMPL_PROPERTY_GETTER(Node, nextSibling)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto* instance = nodeInstance->nextSibling();
  return instance != nullptr ? instance->jsObject : JS_NULL;
}

IMPL_PROPERTY_GETTER(Node, nodeType)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return JS_NewUint32(ctx, nodeInstance->nodeType);
}

IMPL_PROPERTY_GETTER(Node, textContent)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return nodeInstance->internalGetTextContent();
}
IMPL_PROPERTY_SETTER(Node, textContent)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  nodeInstance->internalSetTextContent(argv[0]);
  return JS_NULL;
}

bool NodeInstance::isConnected() const {
  return getFlag(kIsConnectedFlag);
}
DocumentInstance* NodeInstance::ownerDocument() {
  if (nodeType == NodeType::DOCUMENT_NODE) {
    return nullptr;
  }

  return document();
}
NodeInstance* NodeInstance::firstChild() {
  if (!getFlag(kIsContainerFlag)) {
    return nullptr;
  }

  return m_firstChild;
}
NodeInstance* NodeInstance::lastChild() {
  if (!getFlag(kIsConnectedFlag)) {
    return nullptr;
  }

  return m_lastChild;
}
NodeInstance* NodeInstance::previousSibling() {
  return m_previousSibling;
}
NodeInstance* NodeInstance::nextSibling() {
  return m_nextSibling;
}

// Returns true if DOM mutation should be proceeded.
static inline bool collectChildrenAndRemoveFromOldParent(NodeInstance& node, NodeVector& nodes, JSValue* exception) {
  if (node.isDocumentFragment()) {
  }
}

NodeInstance* NodeInstance::internalAppendChild(NodeInstance* newChild, JSValue* exception) {
  assert(newChild != nullptr);
  // Make sure adding the new child is ok
  if (!ensurePreInsertionValidity(*newChild, nullptr, nullptr, exception)) {
    return newChild;
  }

  //  arrayPushValue(m_ctx, childNodes, node->jsObject);
  //  node->setParentNode(this);
  //
  //  node->_notifyNodeInsert(this);
  //
  //  std::string nodeEventTargetId = std::to_string(node->m_eventTargetId);
  //  std::string position = std::string("beforeend");
  //
  //  std::unique_ptr<NativeString> args_01 = stringToNativeString(nodeEventTargetId);
  //  std::unique_ptr<NativeString> args_02 = stringToNativeString(position);

  //  m_context->uiCommandBuffer()->addCommand(m_eventTargetId, UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);
}

void NodeInstance::internalRemove() {
  if (JS_IsNull(parentNode))
    return;
  auto* parent = static_cast<NodeInstance*>(JS_GetOpaque(parentNode, Node::classId(parentNode)));
  parent->internalRemoveChild(this);
}
void NodeInstance::internalClearChild() {
  int32_t len = arrayGetLength(m_ctx, childNodes);

  for (int i = 0; i < len; i++) {
    JSValue v = JS_GetPropertyUint32(m_ctx, childNodes, i);
    auto* node = static_cast<NodeInstance*>(JS_GetOpaque(v, Node::classId(v)));
    node->removeParentNode();
    node->_notifyNodeRemoved(this);
    node->m_context->uiCommandBuffer()->addCommand(node->m_eventTargetId, UICommand::removeNode, nullptr);
    JS_FreeValue(m_ctx, v);
  }

  JS_SetPropertyStr(m_ctx, childNodes, "length", JS_NewUint32(m_ctx, 0));
}
NodeInstance* NodeInstance::internalRemoveChild(NodeInstance* node) {
  int32_t idx = arrayFindIdx(m_ctx, childNodes, node->jsObject);

  if (idx != -1) {
    arraySpliceValue(m_ctx, childNodes, idx, 1);
    node->removeParentNode();
    node->_notifyNodeRemoved(this);
    node->m_context->uiCommandBuffer()->addCommand(node->m_eventTargetId, UICommand::removeNode, nullptr);
  }

  return node;
}
JSValue NodeInstance::internalInsertBefore(NodeInstance* node, NodeInstance* referenceNode) {
  if (referenceNode == nullptr) {
    internalAppendChild(node);
  } else {
    if (JS_VALUE_GET_PTR(referenceNode->parentNode) != JS_VALUE_GET_PTR(jsObject)) {
      return JS_ThrowTypeError(m_ctx, "Uncaught TypeError: Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.");
    }

    auto parentNodeValue = referenceNode->parentNode;
    auto* parent = static_cast<NodeInstance*>(JS_GetOpaque(parentNodeValue, Node::classId(parentNodeValue)));
    if (parent != nullptr) {
      JSValue parentChildNodes = parent->childNodes;
      int32_t idx = arrayFindIdx(m_ctx, parentChildNodes, referenceNode->jsObject);

      if (idx == -1) {
        return JS_ThrowTypeError(m_ctx, "Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.");
      }

      arrayInsert(m_ctx, parentChildNodes, idx, node->jsObject);
      node->setParentNode(parent);
      node->_notifyNodeInsert(parent);

      std::string nodeEventTargetId = std::to_string(node->m_eventTargetId);
      std::string position = std::string("beforebegin");

      std::unique_ptr<NativeString> args_01 = stringToNativeString(nodeEventTargetId);
      std::unique_ptr<NativeString> args_02 = stringToNativeString(position);

      m_context->uiCommandBuffer()->addCommand(referenceNode->m_eventTargetId, UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);
    }
  }

  return JS_NULL;
}
JSValue NodeInstance::internalGetTextContent() {
  return JS_NULL;
}
void NodeInstance::internalSetTextContent(JSValue content) {}
JSValue NodeInstance::internalReplaceChild(NodeInstance* newChild, NodeInstance* oldChild) {
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

  std::string newChildEventTargetId = std::to_string(newChild->m_eventTargetId);
  std::string position = std::string("afterend");

  std::unique_ptr<NativeString> args_01 = stringToNativeString(newChildEventTargetId);
  std::unique_ptr<NativeString> args_02 = stringToNativeString(position);

  m_context->uiCommandBuffer()->addCommand(oldChild->m_eventTargetId, UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);

  m_context->uiCommandBuffer()->addCommand(oldChild->m_eventTargetId, UICommand::removeNode, nullptr);

  return oldChild->jsObject;
}

bool NodeInstance::isDescendantOf(const NodeInstance* other) const {
  assert(this);

  // Return true if other is an ancestor of this, otherwise false
  if (!other || isConnected() != other->isConnected())
    return false;
  for (const NodeInstance* n = parentNode(); n; n = n->parentNode()) {
    if (n == other)
      return true;
  }
  return false;
}

bool NodeInstance::contains(const NodeInstance* node) const {
  if (!node) {
    return false;
  }
  return this == node || node->isDescendantOf(this);
}

NodeInstance* NodeInstance::parentNode() const {
  return m_parent;
}

NodeInstance& NodeInstance::treeRoot() const {
  const NodeInstance* node = this;
  while (node->parentNode()) {
    node = node->parentNode();
  }
  return const_cast<NodeInstance&>(*node);
}

void NodeInstance::setParentNode(NodeInstance* parent) {
  if (!JS_IsNull(parentNode)) {
    JS_FreeValue(m_ctx, parentNode);
  }

  parentNode = JS_DupValue(m_ctx, parent->jsObject);
}

void NodeInstance::removeParentNode() {
  if (!JS_IsNull(parentNode)) {
    JS_FreeValue(m_ctx, parentNode);
  }

  parentNode = JS_NULL;
}

NodeList* NodeInstance::childNodes() {
  if (m_nodeList == nullptr) {
    return m_nodeList = makeGarbageCollected<NodeList>(this);
  }
  return m_nodeList;
}

NodeInstance::~NodeInstance() {}
void NodeInstance::refer() {
  JS_DupValue(m_ctx, jsObject);
  list_add_tail(&nodeLink.link, &m_context->node_job_list);
}
void NodeInstance::unrefer() {
  list_del(&nodeLink.link);
  JS_FreeValue(m_ctx, jsObject);
}
void NodeInstance::_notifyNodeRemoved(NodeInstance* node) {}
void NodeInstance::_notifyNodeInsert(NodeInstance* node) {}
void NodeInstance::ensureDetached(NodeInstance* node) {
  auto* nodeParent = static_cast<NodeInstance*>(JS_GetOpaque(node->parentNode, Node::classId(node->parentNode)));

  if (nodeParent != nullptr) {
    int32_t idx = arrayFindIdx(m_ctx, nodeParent->childNodes, node->jsObject);
    if (idx != -1) {
      node->_notifyNodeRemoved(nodeParent);
      arraySpliceValue(m_ctx, nodeParent->childNodes, idx, 1);
      node->removeParentNode();
    }
  }
}

void NodeInstance::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  EventTargetInstance::trace(rt, val, mark_func);

  // Should check object is already inited before gc mark.
  if (JS_IsObject(parentNode))
    JS_MarkValue(rt, parentNode, mark_func);
}

// ensurePreInsertionValidity() is an implementation of step 2 to 6 of
// https://dom.spec.whatwg.org/#concept-node-ensure-pre-insertion-validity and
// https://dom.spec.whatwg.org/#concept-node-replace .
bool NodeInstance::ensurePreInsertionValidity(const NodeInstance& newChild, const NodeInstance* next, const NodeInstance* oldChild, JSValue* exception) const {
  assert(!(next && oldChild));

  // Use common case fast path if possible.
  if ((newChild.isElementNode() || newChild.isTextNode()) && isElementNode()) {
    // 2. If node is a host-including inclusive ancestor of parent, throw a
    // HierarchyRequestError.
    if (IsHostIncludingInclusiveAncestorOfThis(new_child, exception_state))
      return false;
    // 3. If child is not null and its parent is not parent, then throw a
    // NotFoundError.
    return CheckReferenceChildParent(*this, next, old_child, exception_state);
  }
}

// Returns true if |new_child| contains this node. In that case,
// https://dom.spec.whatwg.org/#concept-tree-host-including-inclusive-ancestor
bool NodeInstance::isHostIncludingInclusiveAncestorOfThis(const NodeInstance& newChild, JSValue* exception) const {
  // Non-ContainerNode contains nothing.
  if (!newChild.isContainerNode())
    return false;

  bool childContainParent = false;

  const NodeInstance& root = treeRoot();
  if (root.isDocumentFragment()) {
    auto fragment = static_cast<const DocumentFragmentInstance*>(&root);
    if (fragment && fragment->isTEmp)
  } else {
    childContainParent = newChild.contains(this);
  }
}

}  // namespace kraken::binding::qjs
