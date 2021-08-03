/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "node.h"
#include "kraken_bridge.h"
#include "element.h"
#include "document.h"
#include "text_node.h"
#include "bindings/qjs/qjs_patch.h"

namespace kraken::binding::qjs {

void bindNode(std::unique_ptr<JSContext> &context) {
  auto *constructor = Node::instance(context.get());
  context->defineGlobalProperty("Node", constructor->classObject);
}

OBJECT_INSTANCE_IMPL(Node);

JSValue Node::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}

JSClassID Node::classId() {
  assert_m(false, "classId is not implemented");
}

JSClassID Node::classId(JSValue &value) {
  JSClassID classId = JSValueGetClassId(value);
  if (classId == Element::classId() || Document::classId()) {
    return classId;
  }

  assert_m(false, "can not identify value type.");
}

JSValue Node::cloneNode(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto selfInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));

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

  if (selfInstance->nodeType == NodeType::ELEMENT_NODE) {
    auto element = static_cast<ElementInstance *>(selfInstance);

    JSValue rootElement = copyNodeValue(ctx, static_cast<NodeInstance *>(element));
    auto rootNodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(rootElement, Node::classId(rootElement)));

    if (deep) {
      traverseCloneNode(ctx, static_cast<ElementInstance *>(element), static_cast<ElementInstance *>(rootNodeInstance));
    }
    return rootNodeInstance->instanceObject;
  } else if (selfInstance->nodeType == NodeType::TEXT_NODE) {
    auto textNode = static_cast<TextNodeInstance *>(selfInstance);
    JSValue newTextNode = copyNodeValue(ctx, static_cast<NodeInstance *>(textNode));
    return newTextNode;
  } else {
    return JS_NULL;
  }
  return JS_NULL;
}
JSValue Node::appendChild(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first argument is required.");
  }

  auto selfInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  if (selfInstance == nullptr) return JS_ThrowTypeError(ctx, "this object is not a instance of Node.");
  JSValue &nodeValue = argv[0];

  if (!JS_IsObject(nodeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.");
  }

  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(nodeValue, Node::classId(nodeValue)));

  if (nodeInstance == nullptr || nodeInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.");
  }

  if (nodeInstance->eventTargetId == HTML_TARGET_ID || nodeInstance == selfInstance) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': The new child element contains the parent.");
  }

  selfInstance->internalAppendChild(nodeInstance);
  return nodeInstance->instanceObject;
}
JSValue Node::remove(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto selfInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  selfInstance->internalRemove();
  return JS_UNDEFINED;
}
JSValue Node::removeChild(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'removeChild' on 'Node': 1 arguments required");
  }

  JSValue &nodeValue = argv[0];

  if (!JS_IsObject(nodeValue)) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'removeChild' on 'Node': 1st arguments is not object");
  }

  auto selfInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(nodeValue, Node::classId(nodeValue)));

  if (nodeInstance == nullptr || nodeInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeChild' on 'Node': 1st arguments is not a Node object.");
  }

  auto removedNode = selfInstance->internalRemoveChild(nodeInstance);
  return removedNode->instanceObject;
}
JSValue Node::insertBefore(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'insertBefore' on 'Node': 2 arguments is required.");
  }

  JSValue &nodeValue = argv[0];
  JSValue &referenceNodeValue = argv[1];

  if (!JS_IsObject(nodeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'insertBefore' on 'Node': the node element is not object.");
  }

  NodeInstance *referenceInstance = nullptr;

  if (JS_IsObject(referenceNodeValue)) {
    referenceInstance = static_cast<NodeInstance *>(JS_GetOpaque(referenceNodeValue, Node::classId(referenceNodeValue)));
  } else if (!JS_IsNull(referenceNodeValue)) {
    return JS_ThrowTypeError(ctx, "TypeError: Failed to execute 'insertBefore' on 'Node': parameter 2 is not of type 'Node'");
  }

  auto selfInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(nodeValue, Node::classId(nodeValue)));

  if (nodeInstance == nullptr || nodeInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'insertBefore' on 'Node': parameter 1 is not of type 'Node'");
  }

  return selfInstance->internalInsertBefore(nodeInstance, referenceInstance);
}
JSValue Node::replaceChild(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 2 arguments required");
  }

  JSValue &newChildValue = argv[0];
  JSValue &oldChildValue = argv[1];

  if (!JS_IsObject(newChildValue)) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 1 arguments is not object");
  }

  if (!JS_IsObject(oldChildValue)) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 2 arguments is not object.");
  }

  auto selfInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto newChildInstance = static_cast<NodeInstance *>(JS_GetOpaque(newChildValue, Node::classId(newChildValue)));
  auto oldChildInstance = static_cast<NodeInstance *>(JS_GetOpaque(oldChildValue, Node::classId(oldChildValue)));

  if (oldChildInstance == nullptr || oldChildInstance->parentNode != selfInstance ||
      oldChildInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx,
                 "Failed to execute 'replaceChild' on 'Node': The node to be replaced is not a child of this node.");
  }

  if (newChildInstance == nullptr || newChildInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'replaceChild' on 'Node': The new node is not a type of node.");
  }

  return selfInstance->internalReplaceChild(newChildInstance, oldChildInstance);
}

void Node::traverseCloneNode(QjsContext *ctx, NodeInstance *element, NodeInstance *parentElement) {
  for (auto iter : element->childNodes) {
    JSValue newNode = copyNodeValue(ctx, static_cast<NodeInstance *>(iter));
    auto newNodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(newNode, Node::classId(newNode)));
    parentElement->internalAppendChild(newNodeInstance);
    // element node needs recursive child nodes.
    if (iter->nodeType == NodeType::ELEMENT_NODE) {
      traverseCloneNode(ctx, static_cast<ElementInstance *>(iter), static_cast<ElementInstance *>(newNodeInstance));
    }
  }
}

JSValue Node::copyNodeValue(QjsContext *ctx, NodeInstance *node) {
  if (node->nodeType == NodeType::ELEMENT_NODE) {
    auto *element = reinterpret_cast<ElementInstance *>(node);

    /* createElement */
    std::string tagName = element->getRegisteredTagName();
    JSValue arguments[] = {
      JS_NewString(element->m_ctx, tagName.c_str())
    };
    JSValue newElementValue = JS_CallConstructor(element->context()->ctx(), Element::instance(element->context())->classObject, 1, arguments);
    auto *newElement = static_cast<ElementInstance *>(JS_GetOpaque(newElementValue, Node::classId(newElementValue)));

    /* copy attributes */
    newElement->m_attributes->copyWith(element->m_attributes);

    /* copy style */
    newElement->m_style->copyWith(element->m_style);

    std::string newNodeEventTargetId = std::to_string(newElement->eventTargetId);
    NativeString *args_01 = stringToNativeString(newNodeEventTargetId);
    foundation::UICommandBuffer::instance(newElement->context()->getContextId())
        ->addCommand(element->eventTargetId, UICommand::cloneNode, *args_01, nullptr);

    return newElement->instanceObject;
  } else if (node->nodeType == TEXT_NODE) {
    auto *textNode = reinterpret_cast<TextNodeInstance *>(node);
    JSValue textContent = textNode->internalGetTextContent();
    JSValue arguments[] = {
      textContent
    };
    return JS_CallConstructor(ctx, TextNode::instance(textNode->m_context)->classObject, 1, arguments);
  }
  return JS_NULL;
}

PROP_GETTER(Node, isConnected)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return JS_NewBool(ctx, nodeInstance->isConnected());
}
PROP_SETTER(Node, isConnected)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Node, ownerDocument)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return nodeInstance->m_document->instanceObject;
}
PROP_SETTER(Node, ownerDocument)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Node, firstChild)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto *instance = nodeInstance->firstChild();
  return instance != nullptr ? instance->instanceObject : JS_NULL;
}
PROP_SETTER(Node, firstChild)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Node, lastChild)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto *instance = nodeInstance->lastChild();
  return instance != nullptr ? instance->instanceObject : JS_NULL;
}
PROP_SETTER(Node, lastChild)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Node, parentNode)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  if (nodeInstance->parentNode == nullptr) return JS_NULL;
  return nodeInstance->parentNode->instanceObject;
}
PROP_SETTER(Node, parentNode)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Node, childNodes)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  JSValue arrayObject = JS_NewArray(ctx);
  size_t len = nodeInstance->childNodes.size();
  for (int i = 0; i < len; i ++) {
    JS_SetPropertyUint32(ctx, arrayObject, i, JS_DupValue(nodeInstance->m_ctx, nodeInstance->childNodes[i]->instanceObject));
  }
  return arrayObject;
}
PROP_SETTER(Node, childNodes)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Node, previousSibling)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto *instance = nodeInstance->previousSibling();
  return instance != nullptr ? instance->instanceObject : JS_NULL;
}
PROP_SETTER(Node, previousSibling)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Node, nextSibling)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto *instance = nodeInstance->nextSibling();
  return instance != nullptr ? instance->instanceObject : JS_NULL;
}
PROP_SETTER(Node, nextSibling)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Node, nodeType)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return JS_NewUint32(ctx, nodeInstance->nodeType);
}
PROP_SETTER(Node, nodeType)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Node, textContent)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return nodeInstance->internalGetTextContent();
}
PROP_SETTER(Node, textContent)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *nodeInstance = static_cast<NodeInstance *>(JS_GetOpaque(this_val, Node::classId(this_val)));
  nodeInstance->internalSetTextContent(argv[0]);
  return JS_NULL;
}

bool NodeInstance::isConnected() {
  bool _isConnected = eventTargetId == HTML_TARGET_ID;
  auto parent = parentNode;

  while (parent != nullptr && !_isConnected) {
    _isConnected = parent->eventTargetId == HTML_TARGET_ID;
    parent = parent->parentNode;
  }

  return _isConnected;
}
DocumentInstance *NodeInstance::ownerDocument() {
  if (nodeType == NodeType::DOCUMENT_NODE) {
    return nullptr;
  }

  return document();
}
NodeInstance *NodeInstance::firstChild() {
  if (childNodes.empty()) {
    return nullptr;
  }
  return childNodes.front();
}
NodeInstance *NodeInstance::lastChild() {
  if (childNodes.empty()) {
    return nullptr;
  }
  return childNodes.back();
}
NodeInstance *NodeInstance::previousSibling() {
  if (parentNode == nullptr) return nullptr;

  auto &&parentChildNodes = parentNode->childNodes;
  auto it = std::find(parentChildNodes.begin(), parentChildNodes.end(), this);

  if (parentChildNodes.size() < 2) {
    return nullptr;
  }

  if (it != parentChildNodes.begin()) {
    return *(it - 1);
  }

  return nullptr;
}
NodeInstance *NodeInstance::nextSibling() {
  if (parentNode == nullptr) return nullptr;

  auto &&parentChildNodes = parentNode->childNodes;
  auto it = std::find(parentChildNodes.begin(), parentChildNodes.end(), this);

  if ((it + 1) != parentChildNodes.end()) {
    return *(it + 1);
  }

  return nullptr;
}
void NodeInstance::internalAppendChild(NodeInstance *node) {
  ensureDetached(node);
  childNodes.emplace_back(node);
  node->parentNode = this;
  node->refer();

  node->_notifyNodeInsert(this);

  std::string nodeEventTargetId = std::to_string(node->eventTargetId);
  std::string position = std::string("beforeend");

  NativeString *args_01 = stringToNativeString(nodeEventTargetId);
  NativeString *args_02 = stringToNativeString(position);

  foundation::UICommandBuffer::instance(m_context->getContextId())
      ->addCommand(eventTargetId, UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);
}
void NodeInstance::internalRemove() {
  if (parentNode == nullptr) return;
  parentNode->internalRemoveChild(this);
}
NodeInstance *NodeInstance::internalRemoveChild(NodeInstance *node) {
  auto it = std::find(childNodes.begin(), childNodes.end(), node);

  if (it != childNodes.end()) {
    childNodes.erase(it);
    node->parentNode = nullptr;
    node->unrefer();
    node->_notifyNodeRemoved(this);
    foundation::UICommandBuffer::instance(node->m_context->getContextId())
        ->addCommand(node->eventTargetId, UICommand::removeNode, nullptr);
  }

  return node;
}
JSValue NodeInstance::internalInsertBefore(NodeInstance *node, NodeInstance *referenceNode) {
  if (referenceNode == nullptr) {
    internalAppendChild(node);
  } else {
    if (referenceNode->parentNode != this) {
      return JS_ThrowTypeError(
          m_ctx,
          "Uncaught TypeError: Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.");
    }

    ensureDetached(node);
    auto parent = referenceNode->parentNode;
    if (parent != nullptr) {
      auto &&parentChildNodes = parent->childNodes;
      auto it = std::find(parentChildNodes.begin(), parentChildNodes.end(), referenceNode);

      if (it == parentChildNodes.end()) {
        return JS_ThrowTypeError(m_ctx, "Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.");
      }

      parentChildNodes.insert(it, node);
      node->parentNode = parent;
      node->refer();
      node->_notifyNodeInsert(parent);

      std::string nodeEventTargetId = std::to_string(node->eventTargetId);
      std::string position = std::string("beforebegin");

      NativeString *args_01 = stringToNativeString(nodeEventTargetId);
      NativeString *args_02 = stringToNativeString(position);

      foundation::UICommandBuffer::instance(m_context->getContextId())
          ->addCommand(referenceNode->eventTargetId, UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);
    }
  }

  return JS_NULL;
}
JSValue NodeInstance::internalGetTextContent() {
  return JS_NULL;
}
void NodeInstance::internalSetTextContent(JSValue content) {}
JSValue NodeInstance::internalReplaceChild(NodeInstance *newChild, NodeInstance *oldChild) {
  ensureDetached(newChild);
  assert_m(newChild->parentNode == nullptr, "ReplaceChild Error: newChild was not detached.");
  oldChild->parentNode = nullptr;
  oldChild->unrefer();

  auto childIndex = std::find(childNodes.begin(), childNodes.end(), oldChild);
  if (childIndex == childNodes.end()) {
    return JS_ThrowTypeError(m_ctx, "Failed to execute 'replaceChild' on 'Node': old child is not exist on childNodes.");
  }

  newChild->parentNode = this;
  childNodes.erase(childIndex);
  childNodes.insert(childIndex, newChild);
  newChild->refer();

  oldChild->_notifyNodeRemoved(this);
  newChild->_notifyNodeInsert(this);

  std::string newChildEventTargetId = std::to_string(newChild->eventTargetId);
  std::string position = std::string("afterend");

  NativeString *args_01 = stringToNativeString(newChildEventTargetId);
  NativeString *args_02 = stringToNativeString(position);

  foundation::UICommandBuffer::instance(m_context->getContextId())
      ->addCommand(oldChild->eventTargetId, UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);

  foundation::UICommandBuffer::instance(m_context->getContextId())
      ->addCommand(oldChild->eventTargetId, UICommand::removeNode, nullptr);

  return oldChild->instanceObject;
}

NodeInstance::~NodeInstance() {
  if (m_context->isValid()) {
    for (auto &node : childNodes) {
      node->parentNode = nullptr;
      node->unrefer();
      assert(node->_referenceCount <= 0 &&
             ("Node recycled with a dangling node " + std::to_string(node->eventTargetId)).c_str());
    }
  }
}

void NodeInstance::refer() {
  if (_referenceCount == 0) {
    JS_DupValue(m_ctx, instanceObject);
  }
  _referenceCount++;
}
void NodeInstance::unrefer() {
  _referenceCount--;
  if (_referenceCount == 0 && m_context->isValid()) {
    JS_FreeValue(m_ctx, instanceObject);
  }
}
void NodeInstance::_notifyNodeRemoved(NodeInstance *node) {}
void NodeInstance::_notifyNodeInsert(NodeInstance *node) {}
void NodeInstance::ensureDetached(NodeInstance *node) {
  if (node->parentNode != nullptr) {
    auto it = std::find(node->parentNode->childNodes.begin(), node->parentNode->childNodes.end(), node);
    if (it != node->parentNode->childNodes.end()) {
      node->_notifyNodeRemoved(node->parentNode);
      node->parentNode->childNodes.erase(it);
      node->parentNode = nullptr;
      node->unrefer();
    }
  }
}

} // namespace kraken::binding::qjs
