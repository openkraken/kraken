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

void bindNode(std::unique_ptr<JSContext>& context) {
  auto* constructor = Node::instance(context.get());
  context->defineGlobalProperty("Node", constructor->classObject);
}

JSValue Node::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
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

JSValue Node::cloneNode(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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

  if (selfInstance->nodeType == NodeType::ELEMENT_NODE) {
    JSValue newElement = copyNodeValue(ctx, selfInstance);
    auto newElementInstance = static_cast<NodeInstance*>(JS_GetOpaque(newElement, Node::classId(newElement)));

    if (deep) {
      traverseCloneNode(ctx, selfInstance, newElementInstance);
    }
    return newElementInstance->instanceObject;
  } else if (selfInstance->nodeType == NodeType::TEXT_NODE) {
    auto textNode = static_cast<TextNodeInstance*>(selfInstance);
    JSValue newTextNode = copyNodeValue(ctx, static_cast<NodeInstance*>(textNode));
    return newTextNode;
  } else if (selfInstance->nodeType == NodeType::DOCUMENT_FRAGMENT_NODE) {
    JSValue newFragment = JS_CallConstructor(ctx, DocumentFragment::instance(selfInstance->m_context)->classObject, 0, nullptr);
    auto* newFragmentInstance = static_cast<NodeInstance*>(JS_GetOpaque(newFragment, Node::classId(newFragment)));

    if (deep) {
      traverseCloneNode(ctx, selfInstance, newFragmentInstance);
    }

    return newFragment;
  }
  return JS_NULL;
}
JSValue Node::appendChild(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first argument is required.");
  }

  auto selfInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  if (selfInstance == nullptr)
    return JS_ThrowTypeError(ctx, "this object is not a instance of Node.");
  JSValue nodeValue = argv[0];

  if (!JS_IsObject(nodeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.");
  }

  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(nodeValue, Node::classId(nodeValue)));

  if (nodeInstance == nullptr || nodeInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.");
  }

  if (nodeInstance->m_eventTargetId == HTML_TARGET_ID || nodeInstance == selfInstance) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'appendChild' on 'Node': The new child element contains the parent.");
  }

  if (nodeInstance->hasNodeFlag(NodeInstance::NodeFlag::IsDocumentFragment)) {
    for (auto& childNode : nodeInstance->childNodes) {
      selfInstance->internalAppendChild(childNode);
    }
    nodeInstance->childNodes.clear();
  } else {
    selfInstance->ensureDetached(nodeInstance);
    selfInstance->internalAppendChild(nodeInstance);
  }

  return JS_DupValue(ctx, nodeInstance->instanceObject);
}
JSValue Node::remove(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto selfInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  selfInstance->internalRemove();
  return JS_UNDEFINED;
}
JSValue Node::removeChild(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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
  return JS_DupValue(ctx, removedNode->instanceObject);
}
JSValue Node::insertBefore(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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

  if (nodeInstance->hasNodeFlag(NodeInstance::NodeFlag::IsDocumentFragment)) {
    for (auto& childNode : nodeInstance->childNodes) {
      selfInstance->internalInsertBefore(childNode, referenceInstance);
    }
    nodeInstance->childNodes.clear();
  } else {
    selfInstance->ensureDetached(nodeInstance);
    selfInstance->internalInsertBefore(nodeInstance, referenceInstance);
  }

  return JS_NULL;
}
JSValue Node::replaceChild(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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

  if (oldChildInstance == nullptr || oldChildInstance->parentNode != selfInstance || oldChildInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'replaceChild' on 'Node': The node to be replaced is not a child of this node.");
  }

  if (newChildInstance == nullptr || newChildInstance->document() != selfInstance->document()) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'replaceChild' on 'Node': The new node is not a type of node.");
  }

  if (newChildInstance->hasNodeFlag(NodeInstance::NodeFlag::IsDocumentFragment)) {
    for (auto& childNode : newChildInstance->childNodes) {
      selfInstance->internalInsertBefore(childNode, oldChildInstance);
    }
    selfInstance->internalRemoveChild(oldChildInstance);
    newChildInstance->childNodes.clear();
  } else {
    selfInstance->ensureDetached(newChildInstance);
    selfInstance->internalReplaceChild(newChildInstance, oldChildInstance);
  }
  return JS_DupValue(ctx, oldChildInstance->instanceObject);
}

void Node::traverseCloneNode(QjsContext* ctx, NodeInstance* baseNode, NodeInstance* targetNode) {
  for (auto node : baseNode->childNodes) {
    JSValue newNode = copyNodeValue(ctx, node);
    auto newNodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(newNode, Node::classId(newNode)));
    targetNode->ensureDetached(newNodeInstance);
    targetNode->internalAppendChild(newNodeInstance);
    // element node needs recursive child nodes.
    if (node->nodeType == NodeType::ELEMENT_NODE) {
      traverseCloneNode(ctx, node, newNodeInstance);
    }
    JS_FreeValue(ctx, newNode);
  }
}

JSValue Node::copyNodeValue(QjsContext* ctx, NodeInstance* node) {
  if (node->nodeType == NodeType::ELEMENT_NODE) {
    auto* element = reinterpret_cast<ElementInstance*>(node);

    /* createElement */
    std::string tagName = element->getRegisteredTagName();
    JSValue tagNameValue = JS_NewString(element->m_ctx, tagName.c_str());
    JSValue arguments[] = {tagNameValue};
    JSValue newElementValue = JS_CallConstructor(element->context()->ctx(), Element::instance(element->context())->classObject, 1, arguments);
    JS_FreeValue(ctx, tagNameValue);

    auto* newElement = static_cast<ElementInstance*>(JS_GetOpaque(newElementValue, Node::classId(newElementValue)));

    /* copy attributes */
    newElement->m_attributes->copyWith(element->m_attributes);

    /* copy style */
    newElement->m_style->copyWith(element->m_style);

    /* copy properties */
    ElementInstance::copyNodeProperties(newElement, element);

    std::string newNodeEventTargetId = std::to_string(newElement->m_eventTargetId);
    NativeString* args_01 = stringToNativeString(newNodeEventTargetId);
    foundation::UICommandBuffer::instance(newElement->context()->getContextId())->addCommand(element->m_eventTargetId, UICommand::cloneNode, *args_01, nullptr);

    return newElement->instanceObject;
  } else if (node->nodeType == TEXT_NODE) {
    auto* textNode = reinterpret_cast<TextNodeInstance*>(node);
    JSValue textContent = textNode->internalGetTextContent();
    JSValue arguments[] = {textContent};
    JSValue result = JS_CallConstructor(ctx, TextNode::instance(textNode->m_context)->classObject, 1, arguments);
    JS_FreeValue(ctx, textContent);
    return result;
  }
  return JS_NULL;
}

PROP_GETTER(NodeInstance, isConnected)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return JS_NewBool(ctx, nodeInstance->isConnected());
}
PROP_SETTER(NodeInstance, isConnected)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(NodeInstance, ownerDocument)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return JS_DupValue(ctx, nodeInstance->m_document->instanceObject);
}
PROP_SETTER(NodeInstance, ownerDocument)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(NodeInstance, firstChild)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto* instance = nodeInstance->firstChild();
  return instance != nullptr ? JS_DupValue(ctx, instance->instanceObject) : JS_NULL;
}
PROP_SETTER(NodeInstance, firstChild)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(NodeInstance, lastChild)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto* instance = nodeInstance->lastChild();
  return instance != nullptr ? JS_DupValue(ctx, instance->instanceObject) : JS_NULL;
}
PROP_SETTER(NodeInstance, lastChild)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(NodeInstance, parentNode)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return JS_DupValue(ctx, nodeInstance->parentNode->instanceObject);
}
PROP_SETTER(NodeInstance, parentNode)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(NodeInstance, previousSibling)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto* instance = nodeInstance->previousSibling();
  return instance != nullptr ? JS_DupValue(ctx, instance->instanceObject) : JS_NULL;
}
PROP_SETTER(NodeInstance, previousSibling)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(NodeInstance, nextSibling)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto* instance = nodeInstance->nextSibling();
  return instance != nullptr ? JS_DupValue(ctx, instance->instanceObject) : JS_NULL;
}
PROP_SETTER(NodeInstance, nextSibling)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(NodeInstance, nodeType)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return JS_NewUint32(ctx, nodeInstance->nodeType);
}
PROP_SETTER(NodeInstance, nodeType)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(NodeInstance, textContent)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  return nodeInstance->internalGetTextContent();
}
PROP_SETTER(NodeInstance, textContent)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  nodeInstance->internalSetTextContent(argv[0]);
  return JS_NULL;
}

PROP_GETTER(NodeInstance, childNodes)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* nodeInstance = static_cast<NodeInstance*>(JS_GetOpaque(this_val, Node::classId(this_val)));
  auto* nodeList = new NodeList(nodeInstance->m_context, nodeInstance);
  return nodeList->jsObject;
}
PROP_SETTER(NodeInstance, childNodes)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

bool NodeInstance::isConnected() {
  bool _isConnected = m_eventTargetId == HTML_TARGET_ID;
  NodeInstance* parent = parentNode;
  while (parent != nullptr && !_isConnected) {
    _isConnected = parent->m_eventTargetId == HTML_TARGET_ID;
    parent = parent->parentNode;
  }

  return _isConnected;
}
DocumentInstance* NodeInstance::ownerDocument() {
  if (nodeType == NodeType::DOCUMENT_NODE) {
    return nullptr;
  }

  return document();
}
NodeInstance* NodeInstance::firstChild() {
  return childNodes.empty() ? nullptr : childNodes[0];
}
NodeInstance* NodeInstance::lastChild() {
  return childNodes.empty() ? nullptr : childNodes[childNodes.size() - 1];
}
NodeInstance* NodeInstance::previousSibling() {
  if (parentNode == nullptr)
    return nullptr;
  auto& parentChildNodes = parentNode->childNodes;
  auto idx = std::find(parentChildNodes.begin(), parentChildNodes.end(), this);

  if (idx == parentChildNodes.begin() || idx == parentChildNodes.end()) {
    return nullptr;
  }

  return *(idx - 1);
}
NodeInstance* NodeInstance::nextSibling() {
  if (parentNode == nullptr)
    return nullptr;

  auto& parentChildNodes = parentNode->childNodes;
  auto idx = std::find(parentChildNodes.begin(), parentChildNodes.end(), this);

  if (idx == parentChildNodes.end() || (idx + 1) == parentChildNodes.end()) {
    return nullptr;
  }

  return *(idx + 1);
}
void NodeInstance::internalAppendChild(NodeInstance* node) {
  childNodes.emplace_back(node);
  node->parentNode = this;

  node->_notifyNodeInsert(this);

  std::string nodeEventTargetId = std::to_string(node->m_eventTargetId);
  std::string position = std::string("beforeend");

  NativeString* args_01 = stringToNativeString(nodeEventTargetId);
  NativeString* args_02 = stringToNativeString(position);

  foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(m_eventTargetId, UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);
}
void NodeInstance::internalRemove() {
  if (parentNode == nullptr)
    return;
  parentNode->internalRemoveChild(this);
}
void NodeInstance::internalClearChild() {
  for (auto& childNode : childNodes) {
    childNode->parentNode = nullptr;
    childNode->_notifyNodeRemoved(this);
    foundation::UICommandBuffer::instance(childNode->m_context->getContextId())->addCommand(childNode->m_eventTargetId, UICommand::removeNode, nullptr);
  }
  childNodes.clear();
}
NodeInstance* NodeInstance::internalRemoveChild(NodeInstance* node) {
  auto idx = std::find(childNodes.begin(), childNodes.end(), node);

  if (idx != childNodes.end()) {
    childNodes.erase(idx);
    node->_notifyNodeRemoved(this);
    foundation::UICommandBuffer::instance(node->m_context->getContextId())->addCommand(node->m_eventTargetId, UICommand::removeNode, nullptr);
  }

  return node;
}
JSValue NodeInstance::internalInsertBefore(NodeInstance* node, NodeInstance* referenceNode) {
  if (referenceNode == nullptr) {
    internalAppendChild(node);
  } else {
    if (referenceNode->parentNode != this) {
      return JS_ThrowTypeError(m_ctx, "Uncaught TypeError: Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.");
    }

    auto* parent = referenceNode->parentNode;
    if (parent != nullptr) {
      auto parentChildNodes = parent->childNodes;
      auto idx = std::find(parentChildNodes.begin(), parentChildNodes.end(), referenceNode);

      if (idx == parentChildNodes.end()) {
        return JS_ThrowTypeError(m_ctx, "Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.");
      }

      parentChildNodes.insert(idx, node);
      node->parentNode = parent;
      node->_notifyNodeInsert(parent);

      std::string nodeEventTargetId = std::to_string(node->m_eventTargetId);
      std::string position = std::string("beforebegin");

      NativeString* args_01 = stringToNativeString(nodeEventTargetId);
      NativeString* args_02 = stringToNativeString(position);

      foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(referenceNode->m_eventTargetId, UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);
    }
  }

  return JS_NULL;
}
JSValue NodeInstance::internalGetTextContent() {
  return JS_NULL;
}
void NodeInstance::internalSetTextContent(JSValue content) {}
JSValue NodeInstance::internalReplaceChild(NodeInstance* newChild, NodeInstance* oldChild) {
  assert_m(newChild->parentNode == nullptr, "ReplaceChild Error: newChild was not detached.");
  oldChild->parentNode = nullptr;

  auto idx = std::find(childNodes.begin(), childNodes.end(), oldChild);
  if (idx == childNodes.end()) {
    return JS_ThrowTypeError(m_ctx, "Failed to execute 'replaceChild' on 'Node': old child is not exist on childNodes.");
  }

  newChild->parentNode = this;

  childNodes.erase(idx);

  oldChild->_notifyNodeRemoved(this);
  newChild->_notifyNodeInsert(this);

  std::string newChildEventTargetId = std::to_string(newChild->m_eventTargetId);
  std::string position = std::string("afterend");

  NativeString* args_01 = stringToNativeString(newChildEventTargetId);
  NativeString* args_02 = stringToNativeString(position);

  foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(oldChild->m_eventTargetId, UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);

  foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(oldChild->m_eventTargetId, UICommand::removeNode, nullptr);

  return oldChild->instanceObject;
}

NodeInstance::~NodeInstance() {}
void NodeInstance::refer() {
  JS_DupValue(m_ctx, instanceObject);
  list_add_tail(&nodeLink.link, &m_context->node_job_list);
}
void NodeInstance::unrefer() {
  list_del(&nodeLink.link);
  JS_FreeValue(m_ctx, instanceObject);
}
void NodeInstance::_notifyNodeRemoved(NodeInstance* node) {}
void NodeInstance::_notifyNodeInsert(NodeInstance* node) {}
void NodeInstance::ensureDetached(NodeInstance* node) {
  auto* parent = node->parentNode;
  if (parent != nullptr) {
    auto idx = std::find(parent->childNodes.begin(), parent->childNodes.end(), node);
    if (idx != parent->childNodes.end()) {
      node->_notifyNodeRemoved(parent);
      parent->childNodes.erase(idx);
      node->parentNode = nullptr;
    }
  }
}

void NodeInstance::gcMark(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  EventTargetInstance::gcMark(rt, val, mark_func);
  for (auto& childNode : childNodes) {
    JS_MarkValue(rt, childNode->instanceObject, mark_func);
  }
}

}  // namespace kraken::binding::qjs
