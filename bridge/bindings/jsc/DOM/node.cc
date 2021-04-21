/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "node.h"
#include "document.h"
#include "foundation/ui_command_callback_queue.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

void bindNode(std::unique_ptr<JSContext> &context) {
  auto node = JSNode::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Node", node->classObject);
}

JSNode::JSNode(JSContext *context) : JSEventTarget(context, "Node") {}
JSNode::JSNode(JSContext *context, const char *name) : JSEventTarget(context, name) {}

std::unordered_map<JSContext *, JSNode *> JSNode::instanceMap{};

JSNode *JSNode::instance(JSContext *context) {
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSNode(context);
  }
  return instanceMap[context];
}

JSNode::~JSNode() {
  instanceMap.erase(context);
}

NodeInstance::~NodeInstance() {
  // The this node is finalized, should tell all children this parent will no longer protecting them.
  if (context->isValid()) {
    for (auto &node : childNodes) {
      node->parentNode = nullptr;
      node->unrefer();
      assert(node->_referenceCount <= 0 &&
             ("Node recycled with a dangling node " + std::to_string(node->eventTargetId)).c_str());
    }
  }

  foundation::UICommandCallbackQueue::instance()->registerCallback(
    [](void *ptr) { delete reinterpret_cast<NativeNode *>(ptr); }, nativeNode);
}

NodeInstance::NodeInstance(JSNode *node, NodeType nodeType)
  : EventTargetInstance(node), nativeNode(new NativeNode(nativeEventTarget)), nodeType(nodeType) {
  m_document = DocumentInstance::instance(context);
}

NodeInstance::NodeInstance(JSNode *node, NodeType nodeType, int64_t targetId)
  : EventTargetInstance(node, targetId), nativeNode(new NativeNode(nativeEventTarget)), nodeType(nodeType) {
  m_document = DocumentInstance::instance(context);
}

// Returns true if node is connected and false otherwise.
bool NodeInstance::isConnected() {
  bool _isConnected = eventTargetId == BODY_TARGET_ID;
  auto parent = parentNode;

  while (parent != nullptr && !_isConnected) {
    _isConnected = parent->eventTargetId == BODY_TARGET_ID;
    parent = parent->parentNode;
  }

  return _isConnected;
}

// The ownerDocument attribute’s getter must return null,
// if this is a document, and this’s node document otherwise.
// https://dom.spec.whatwg.org/#dom-node-ownerdocument
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

JSObjectRef JSNode::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                        const JSValueRef *arguments, JSValueRef *exception) {
  throwJSError(ctx, "Illegal constructor", exception);
  return nullptr;
}

JSValueRef JSNode::copyNodeValue(JSContextRef ctx, NodeInstance *node) {
  if (node->nodeType == NodeType::ELEMENT_NODE) {
    ElementInstance *element = reinterpret_cast<ElementInstance *>(node);

    /* createElement */
    std::string tagName = element->tagName();
    auto newElement = JSElement::buildElementInstance(element->document()->context, tagName);

    /* copy attributes */
    JSStringHolder attributesStringHolder = JSStringHolder(element->document()->context, "attributes");
    JSValueRef attributeValueRef =
      JSObjectGetProperty(ctx, element->object, attributesStringHolder.getString(), nullptr);
    JSObjectRef attributeObjectRef = JSValueToObject(ctx, attributeValueRef, nullptr);
    auto mAttributes = reinterpret_cast<JSElementAttributes *>(JSObjectGetPrivate(attributeObjectRef));

    std::map<std::string, JSStringRef> &attributesMap = mAttributes->getAttributesMap();
    std::vector<JSStringRef> &attributesVector = mAttributes->getAttributesVector();

    (*newElement->getAttributes())->setAttributesMap(attributesMap);
    (*newElement->getAttributes())->setAttributesVector(attributesVector);

    /* copy style */
    newElement->setStyle(element->getStyle());

    std::string newNodeEventTargetId = std::to_string(newElement->eventTargetId);

    NativeString args_01{};
    buildUICommandArgs(newNodeEventTargetId, args_01);

    foundation::UICommandTaskMessageQueue::instance(newElement->contextId)
      ->registerCommand(element->eventTargetId, UICommand::cloneNode, args_01, nullptr);

    return newElement->object;
  } else if (node->nodeType == TEXT_NODE) {
    JSTextNode::TextNodeInstance *textNode = reinterpret_cast<JSTextNode::TextNodeInstance *>(node);

    std::string content = textNode->internalGetTextContent();
    auto newTextNodeInstance = new JSTextNode::TextNodeInstance(JSTextNode::instance(textNode->document()->context),
                                                                JSStringCreateWithUTF8CString(content.c_str()));
    return newTextNodeInstance->object;
  }

  return nullptr;
}

void JSNode::traverseCloneNode(JSContextRef ctx, NodeInstance *element, NodeInstance *parentElement) {
  for (auto iter : element->childNodes) {
    JSValueRef newElementRef = copyNodeValue(ctx, static_cast<NodeInstance *>(iter));
    JSObjectRef newElementObjectRef = JSValueToObject(ctx, newElementRef, nullptr);
    auto newNodeInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(newElementObjectRef));
    parentElement->internalAppendChild(newNodeInstance);
    // element node needs recursive child nodes.
    if (iter->nodeType == NodeType::ELEMENT_NODE) {
      traverseCloneNode(ctx, static_cast<ElementInstance *>(iter), static_cast<ElementInstance *>(newNodeInstance));
    }
  }
}

JSValueRef JSNode::cloneNode(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef *arguments, JSValueRef *exception) {
  auto selfInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(thisObject));

  const JSValueRef deepValue = arguments[0];
  if (!JSValueIsBoolean(ctx, deepValue)) {
    throwJSError(ctx, "Failed to cloneNode: deep should be a Boolean.", exception);
    return nullptr;
  }
  bool deepBooleanRef = JSValueToBoolean(ctx, deepValue);

  if (selfInstance->nodeType == NodeType::ELEMENT_NODE) {
    auto element = static_cast<ElementInstance *>(selfInstance);

    JSValueRef rootElementRef = copyNodeValue(ctx, static_cast<NodeInstance *>(element));
    JSObjectRef rootNodeObjectRef = JSValueToObject(ctx, rootElementRef, nullptr);
    auto rootNodeInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(rootNodeObjectRef));

    if (deepBooleanRef) {
      traverseCloneNode(ctx, static_cast<ElementInstance *>(element), static_cast<ElementInstance *>(rootNodeInstance));
    }

    return rootNodeInstance->object;
  } else if (selfInstance->nodeType == NodeType::TEXT_NODE) {
    auto textNode = static_cast<JSTextNode::TextNodeInstance *>(selfInstance);
    JSValueRef newTextNodeRef = copyNodeValue(ctx, static_cast<NodeInstance *>(textNode));
    JSObjectRef newTextNodeObjectRef = JSValueToObject(ctx, newTextNodeRef, nullptr);
    auto newTextNodeObjectInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(newTextNodeObjectRef));

    return newTextNodeObjectInstance->object;
  } else {
    return nullptr;
  }
}

JSValueRef JSNode::appendChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    throwJSError(ctx, "Failed to execute 'appendChild' on 'Node': first argument is required.", exception);
    return nullptr;
  }

  auto selfInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(thisObject));
  assert_m(selfInstance != nullptr, "this object is not a instance of Node.");
  const JSValueRef nodeValueRef = arguments[0];

  if (!JSValueIsObject(ctx, nodeValueRef)) {
    throwJSError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.", exception);
    return nullptr;
  }

  JSObjectRef nodeObjectRef = JSValueToObject(ctx, nodeValueRef, exception);
  auto nodeInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(nodeObjectRef));

  if (nodeInstance == nullptr || nodeInstance->document() != selfInstance->document()) {
    throwJSError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.", exception);
    return nullptr;
  }

  if (nodeInstance->eventTargetId == BODY_TARGET_ID || nodeInstance == selfInstance) {
    throwJSError(ctx, "Failed to execute 'appendChild' on 'Node': The new child element contains the parent.",
                 exception);
    return nullptr;
  }

  selfInstance->internalAppendChild(nodeInstance);

  return nodeValueRef;
}

JSValueRef JSNode::insertBefore(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 2) {
    throwJSError(ctx, "Failed to execute 'insertBefore' on 'Node': 2 arguments is required.", exception);
    return nullptr;
  }

  const JSValueRef nodeValueRef = arguments[0];
  const JSValueRef referenceNodeValueRef = arguments[1];

  if (!JSValueIsObject(ctx, nodeValueRef)) {
    throwJSError(ctx, "Failed to execute 'insertBefore' on 'Node': the node element is not object.", exception);
    return nullptr;
  }

  JSObjectRef nodeObjectRef = JSValueToObject(ctx, nodeValueRef, exception);
  JSObjectRef referenceNodeObjectRef = nullptr;
  NodeInstance *referenceInstance = nullptr;

  if (JSValueIsObject(ctx, referenceNodeValueRef)) {
    referenceNodeObjectRef = JSValueToObject(ctx, referenceNodeValueRef, exception);
    referenceInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(referenceNodeObjectRef));
  } else if (!JSValueIsNull(ctx, referenceNodeValueRef)) {
    throwJSError(ctx, "TypeError: Failed to execute 'insertBefore' on 'Node': parameter 2 is not of type 'Node'",
                 exception);
    return nullptr;
  }

  auto selfInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(thisObject));
  auto nodeInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(nodeObjectRef));

  if (nodeInstance == nullptr || nodeInstance->document() != selfInstance->document()) {
    throwJSError(ctx, "Failed to execute 'insertBefore' on 'Node': parameter 1 is not of type 'Node'", exception);
    return nullptr;
  }

  selfInstance->internalInsertBefore(nodeInstance, referenceInstance, exception);

  return nullptr;
}

JSValueRef JSNode::replaceChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) {

  if (argumentCount < 2) {
    throwJSError(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 2 arguments required",
                 exception);
    return nullptr;
  }

  const JSValueRef newChildValueRef = arguments[0];
  const JSValueRef oldChildValueRef = arguments[1];

  if (!JSValueIsObject(ctx, newChildValueRef)) {
    throwJSError(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 1 arguments is not object",
                 exception);
    return nullptr;
  }

  JSObjectRef newChildObjectRef = JSValueToObject(ctx, newChildValueRef, exception);

  if (!JSValueIsObject(ctx, oldChildValueRef)) {
    throwJSError(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 2 arguments is not object.",
                 exception);
    return nullptr;
  }

  JSObjectRef oldChildObjectRef = JSValueToObject(ctx, oldChildValueRef, exception);

  auto selfInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(thisObject));
  auto newChildInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(newChildObjectRef));
  auto oldChildInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(oldChildObjectRef));

  if (oldChildInstance == nullptr || oldChildInstance->parentNode != selfInstance ||
      oldChildInstance->document() != selfInstance->document()) {
    throwJSError(ctx,
                 "Failed to execute 'replaceChild' on 'Node': The node to be replaced is not a child of this node.",
                 exception);
    return nullptr;
  }

  if (newChildInstance == nullptr || newChildInstance->document() != selfInstance->document()) {
    throwJSError(ctx, "Failed to execute 'replaceChild' on 'Node': The new node is not a type of node.", exception);
    return nullptr;
  }

  selfInstance->internalReplaceChild(newChildInstance, oldChildInstance, exception);

  return nullptr;
}

void NodeInstance::internalInsertBefore(NodeInstance *node, NodeInstance *referenceNode, JSValueRef *exception) {
  if (referenceNode == nullptr) {
    internalAppendChild(node);
  } else {
    if (referenceNode->parentNode != this) {
      throwJSError(
        _hostClass->ctx,
        "Uncaught TypeError: Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.",
        exception);
      return;
    }

    ensureDetached(node);
    auto parent = referenceNode->parentNode;
    if (parent != nullptr) {
      auto &&parentChildNodes = parent->childNodes;
      auto it = std::find(parentChildNodes.begin(), parentChildNodes.end(), referenceNode);

      if (it == parentChildNodes.end()) {
        throwJSError(_hostClass->ctx,
                     "Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.",
                     exception);
        return;
      }

      parentChildNodes.insert(it, node);
      node->parentNode = parent;
      node->refer();
      node->_notifyNodeInsert(parent);

      std::string nodeEventTargetId = std::to_string(node->eventTargetId);
      std::string position = std::string("beforebegin");

      NativeString args_01{};
      NativeString args_02{};
      buildUICommandArgs(nodeEventTargetId, position, args_01, args_02);

      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(referenceNode->eventTargetId, UICommand::insertAdjacentNode, args_01, args_02, nullptr);
    }
  }
}

JSValueRef JSNode::remove(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                          const JSValueRef *arguments, JSValueRef *exception) {
  auto selfInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(thisObject));
  selfInstance->internalRemove(exception);
  return nullptr;
}

JSValueRef JSNode::removeChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Uncaught TypeError: Failed to execute 'removeChild' on 'Node': 1 arguments required", exception);
    return nullptr;
  }

  const JSValueRef nodeValueRef = arguments[0];

  if (!JSValueIsObject(ctx, nodeValueRef)) {
    throwJSError(ctx, "Uncaught TypeError: Failed to execute 'removeChild' on 'Node': 1st arguments is not object",
                 exception);
    return nullptr;
  }

  JSObjectRef nodeObjectRef = JSValueToObject(ctx, nodeValueRef, exception);

  if (!JSValueIsObject(ctx, nodeObjectRef)) {
    throwJSError(ctx, "Uncaught TypeError: Failed to execute 'removeChild' on 'Node': 1st arguments is not object.",
                 exception);
    return nullptr;
  }

  auto selfInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(thisObject));
  auto nodeInstance = static_cast<NodeInstance *>(JSObjectGetPrivate(nodeObjectRef));

  if (nodeInstance == nullptr || nodeInstance->document() != selfInstance->document()) {
    throwJSError(ctx, "Failed to execute 'removeChild' on 'Node': 1st arguments is not a Node object.", exception);
    return nullptr;
  }

  auto removedNode = selfInstance->internalRemoveChild(nodeInstance, exception);

  return removedNode->object;
}

void NodeInstance::internalAppendChild(NodeInstance *node) {
  ensureDetached(node);
  childNodes.emplace_back(node);
  node->parentNode = this;
  node->refer();

  node->_notifyNodeInsert(this);

  std::string nodeEventTargetId = std::to_string(node->eventTargetId);
  std::string position = std::string("beforeend");

  NativeString args_01{};
  NativeString args_02{};

  buildUICommandArgs(nodeEventTargetId, position, args_01, args_02);

  foundation::UICommandTaskMessageQueue::instance(node->_hostClass->contextId)
    ->registerCommand(eventTargetId, UICommand::insertAdjacentNode, args_01, args_02, nullptr);
}

void NodeInstance::internalRemove(JSValueRef *exception) {
  if (parentNode == nullptr) return;
  parentNode->internalRemoveChild(this, exception);
}

NodeInstance *NodeInstance::internalRemoveChild(NodeInstance *node, JSValueRef *exception) {
  auto it = std::find(childNodes.begin(), childNodes.end(), node);

  if (it != childNodes.end()) {
    childNodes.erase(it);
    node->parentNode = nullptr;
    node->unrefer();
    node->_notifyNodeRemoved(this);
    foundation::UICommandTaskMessageQueue::instance(node->_hostClass->contextId)
      ->registerCommand(node->eventTargetId, UICommand::removeNode, nullptr);
  }

  return node;
}

NodeInstance *NodeInstance::internalReplaceChild(NodeInstance *newChild, NodeInstance *oldChild,
                                                 JSValueRef *exception) {
  ensureDetached(newChild);
  assert_m(newChild->parentNode == nullptr, "ReplaceChild Error: newChild was not detached.");
  oldChild->parentNode = nullptr;
  oldChild->unrefer();

  auto childIndex = std::find(childNodes.begin(), childNodes.end(), oldChild);
  if (childIndex == childNodes.end()) {
    throwJSError(ctx, "Failed to execute 'replaceChild' on 'Node': old child is not exist on childNodes.", exception);
    return nullptr;
  }

  newChild->parentNode = this;
  childNodes.erase(childIndex);
  childNodes.insert(childIndex, newChild);
  newChild->refer();

  oldChild->_notifyNodeRemoved(this);
  newChild->_notifyNodeInsert(this);

  std::string newChildEventTargetId = std::to_string(newChild->eventTargetId);
  std::string position = std::string("afterend");

  NativeString args_01{};
  NativeString args_02{};

  buildUICommandArgs(newChildEventTargetId, position, args_01, args_02);

  foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
    ->registerCommand(oldChild->eventTargetId, UICommand::insertAdjacentNode, args_01, args_02, nullptr);

  foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
    ->registerCommand(oldChild->eventTargetId, UICommand::removeNode, nullptr);

  return oldChild;
}

JSValueRef JSNode::prototypeGetProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getNodePropertyMap();

  if (propertyMap.count(name) == 0) {
    return JSEventTarget::prototypeGetProperty(name, exception);
  }

  return nullptr;
}

JSValueRef NodeInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSNode::getNodePropertyMap();
  auto prototypePropertyMap = JSNode::getNodePrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) {
    JSStringHolder nameStringHolder = JSStringHolder(context, name);
    return JSObjectGetProperty(ctx, prototype<JSNode>()->prototypeObject, nameStringHolder.getString(), exception);
  }

  if (propertyMap.count(name) == 0) {
    return EventTargetInstance::getProperty(name, exception);
  }

  auto property = propertyMap[name];

  switch (property) {
  case JSNode::NodeProperty::isConnected:
    return JSValueMakeBoolean(_hostClass->ctx, isConnected());
  case JSNode::NodeProperty::ownerDocument: {
    auto instance = ownerDocument();
    return instance != nullptr ? instance->object : JSValueMakeNull(ctx);
  }
  case JSNode::NodeProperty::firstChild: {
    auto instance = firstChild();
    return instance != nullptr ? instance->object : JSValueMakeNull(ctx);
  }
  case JSNode::NodeProperty::parentNode: {
    if (parentNode == nullptr) return JSValueMakeNull(ctx);
    return parentNode->object;
  }
  case JSNode::NodeProperty::lastChild: {
    auto instance = lastChild();
    return instance != nullptr ? instance->object : JSValueMakeNull(ctx);
  }
  case JSNode::NodeProperty::previousSibling: {
    auto instance = previousSibling();
    return instance != nullptr ? instance->object : JSValueMakeNull(ctx);
  }
  case JSNode::NodeProperty::nextSibling: {
    auto instance = nextSibling();
    return instance != nullptr ? instance->object : JSValueMakeNull(ctx);
  }
  case JSNode::NodeProperty::childNodes: {
    JSValueRef arguments[childNodes.size()];

    for (int i = 0; i < childNodes.size(); i++) {
      arguments[i] = childNodes[i]->object;
    }

    JSObjectRef array = JSObjectMakeArray(_hostClass->ctx, childNodes.size(), arguments, nullptr);
    return array;
  }
  case JSNode::NodeProperty::nodeType:
    return JSValueMakeNumber(_hostClass->ctx, nodeType);
  case JSNode::NodeProperty::textContent: {
    std::string textContent = internalGetTextContent();
    return JSValueMakeString(_hostClass->ctx, JSStringCreateWithUTF8CString(textContent.c_str()));
  }
  }

  return nullptr;
}

bool NodeInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSNode::getNodePropertyMap();
  auto prototypePropertyMap = JSNode::getNodePrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) return false;

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    if (property == JSNode::NodeProperty::textContent) {
      JSStringRef textContent = JSValueToStringCopy(_hostClass->ctx, value, exception);
      internalSetTextContent(textContent, exception);
    }

    return true;
  } else {
    return EventTargetInstance::setProperty(name, value, exception);
  }
}

void NodeInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventTargetInstance::getPropertyNames(accumulator);

  for (auto &property : JSNode::getNodePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (auto &property : JSNode::getNodePrototypePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::string NodeInstance::internalGetTextContent() {
  return "";
}

void NodeInstance::refer() {
  if (_referenceCount == 0) {
    JSValueProtect(_hostClass->ctx, this->object);
  }
  _referenceCount++;
}

void NodeInstance::unrefer() {
  _referenceCount--;
  if (_referenceCount == 0 && context->isValid()) {
    JSValueUnprotect(_hostClass->ctx, this->object);
  }
}

void NodeInstance::_notifyNodeRemoved(NodeInstance *node) {}
void NodeInstance::_notifyNodeInsert(NodeInstance *node) {}
void NodeInstance::internalSetTextContent(JSStringRef content, JSValueRef *exception) {}

} // namespace kraken::binding::jsc
