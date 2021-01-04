/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "node.h"
#include "bindings/jsc/macros.h"
#include "foundation/ui_command_queue.h"
#include "foundation/ui_command_callback_queue.h"

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

JSNode::NodeInstance::~NodeInstance() {
  // The this node is finalized, should tell all children this parent will no longer protecting them.
  for (auto &node : childNodes) {
    node->parentNode = nullptr;
    node->unrefer();
    assert(node->_referenceCount <= 0 &&
           ("Node recycled with a dangling node " + std::to_string(node->eventTargetId)).c_str());
  }

  foundation::UICommandCallbackQueue::instance(contextId)->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeNode *>(ptr);
  }, nativeNode);
}

JSNode::NodeInstance::NodeInstance(JSNode *node, NodeType nodeType)
  : EventTargetInstance(node), nativeNode(new NativeNode(nativeEventTarget)), nodeType(nodeType) {}

JSNode::NodeInstance::NodeInstance(JSNode *node, NodeType nodeType, int64_t targetId)
  : EventTargetInstance(node, targetId), nativeNode(new NativeNode(nativeEventTarget)), nodeType(nodeType) {}

bool JSNode::NodeInstance::isConnected() {
  bool _isConnected = eventTargetId == BODY_TARGET_ID;
  auto parent = parentNode;

  while (parent != nullptr) {
    _isConnected = parent->eventTargetId == BODY_TARGET_ID;
    parent = parent->parentNode;
  }

  return _isConnected;
}

JSNode::NodeInstance *JSNode::NodeInstance::firstChild() {
  if (childNodes.empty()) {
    return nullptr;
  }
  return childNodes.front();
}

JSNode::NodeInstance *JSNode::NodeInstance::lastChild() {
  if (childNodes.empty()) {
    return nullptr;
  }
  return childNodes.back();
}

JSNode::NodeInstance *JSNode::NodeInstance::previousSibling() {
  if (parentNode == nullptr) return nullptr;

  auto &&parentChildNodes = parentNode->childNodes;
  auto it = std::find(parentChildNodes.begin(), parentChildNodes.end(), this);

  if (parentChildNodes.size() < 2) {
    return nullptr;
  }

  if ((it - 1) != parentChildNodes.end()) {
    return *(it - 1);
  }

  return nullptr;
}

JSNode::NodeInstance *JSNode::NodeInstance::nextSibling() {
  if (parentNode == nullptr) return nullptr;

  auto &&parentChildNodes = parentNode->childNodes;
  auto it = std::find(parentChildNodes.begin(), parentChildNodes.end(), this);

  if ((it + 1) != parentChildNodes.end()) {
    return *(it + 1);
  }

  return nullptr;
}

void JSNode::NodeInstance::ensureDetached(JSNode::NodeInstance *node) {
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

JSValueRef JSNode::appendChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    throwJSError(ctx, "Failed to execute 'appendChild' on 'Node': first argument is required.", exception);
    return nullptr;
  }

  auto selfInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(thisObject));
  assert_m(selfInstance != nullptr, "this object is not a instance of Node.");
  const JSValueRef nodeValueRef = arguments[0];

  if (!JSValueIsObject(ctx, nodeValueRef)) {
    throwJSError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.",
                    exception);
    return nullptr;
  }

  JSObjectRef nodeObjectRef = JSValueToObject(ctx, nodeValueRef, exception);
  auto nodeInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(nodeObjectRef));

  if (nodeInstance == nullptr || nodeInstance->_identify != NODE_IDENTIFY) {
    throwJSError(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.",
                    exception);
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
  JSNode::NodeInstance *referenceInstance = nullptr;

  if (JSValueIsObject(ctx, referenceNodeValueRef)) {
    referenceNodeObjectRef = JSValueToObject(ctx, referenceNodeValueRef, exception);
    referenceInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(referenceNodeObjectRef));
  } else if (!JSValueIsNull(ctx, referenceNodeValueRef)) {
    assert(false);
    throwJSError(ctx, "TypeError: Failed to execute 'insertBefore' on 'Node': parameter 2 is not of type 'Node'",
                    exception);
    return nullptr;
  }

  auto selfInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(thisObject));
  auto nodeInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(nodeObjectRef));

  if (nodeInstance == nullptr || nodeInstance->_identify != NODE_IDENTIFY) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'insertBefore' on 'Node': parameter 1 is not of type 'Node'", exception);
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

  auto selfInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(thisObject));
  auto newChildInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(newChildObjectRef));
  auto oldChildInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(oldChildObjectRef));

  if (oldChildInstance == nullptr || oldChildInstance->parentNode != selfInstance || oldChildInstance->_identify != NODE_IDENTIFY) {
    throwJSError(ctx,
                    "Failed to execute 'replaceChild' on 'Node': The node to be replaced is not a child of this node.",
                    exception);
    return nullptr;
  }

  if (newChildInstance == nullptr || newChildInstance->_identify != NODE_IDENTIFY) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'replaceChild' on 'Node': The new node is not a type of node.", exception);
    return nullptr;
  }

  selfInstance->internalReplaceChild(newChildInstance, oldChildInstance, exception);

  return nullptr;
}

void JSNode::NodeInstance::internalInsertBefore(JSNode::NodeInstance *node, JSNode::NodeInstance *referenceNode,
                                                JSValueRef *exception) {
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
        JSC_THROW_ERROR(_hostClass->ctx, "Failed to execute 'insertBefore' on 'Node': reference node is not a child of this node.", exception);
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
  auto selfInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(thisObject));
  selfInstance->internalRemove(exception);
  return nullptr;
}

JSValueRef JSNode::removeChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Uncaught TypeError: Failed to execute 'removeChild' on 'Node': 1 arguments required",
                    exception);
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

  auto selfInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(thisObject));
  auto nodeInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(nodeObjectRef));

  if (nodeInstance == nullptr || nodeInstance->_identify != NODE_IDENTIFY) {
    throwJSError(ctx, "Failed to execute 'removeChild' on 'Node': 1st arguments is not a Node object.", exception);
    return nullptr;
  }

  auto removedNode = selfInstance->internalRemoveChild(nodeInstance, exception);

  return removedNode->object;
}

void JSNode::NodeInstance::internalAppendChild(JSNode::NodeInstance *node) {
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

void JSNode::NodeInstance::internalRemove(JSValueRef *exception) {
  if (parentNode == nullptr) return;
  parentNode->internalRemoveChild(this, exception);
}

JSNode::NodeInstance *JSNode::NodeInstance::internalRemoveChild(JSNode::NodeInstance *node, JSValueRef *exception) {
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

JSNode::NodeInstance *JSNode::NodeInstance::internalReplaceChild(JSNode::NodeInstance *newChild,
                                                                 JSNode::NodeInstance *oldChild,
                                                                 JSValueRef *exception) {
  ensureDetached(newChild);
  auto parent = oldChild->parentNode;
  oldChild->parentNode = nullptr;
  oldChild->unrefer();

  auto childIndex = std::find(parent->childNodes.begin(), parent->childNodes.end(), oldChild);
  if (childIndex == parent->childNodes.end()) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'replaceChild' on 'Node': old child is not exist on childNodes.", exception);
    return nullptr;
  }

  newChild->parentNode = parent;
  parent->childNodes.erase(childIndex);
  parent->childNodes.insert(childIndex, newChild);
  newChild->refer();

  oldChild->_notifyNodeRemoved(parent);
  newChild->_notifyNodeInsert(parent);

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

  auto property = propertyMap[name];
  switch (property) {
  case NodeProperty::appendChild:
    return m_appendChild.function();
  case NodeProperty::remove:
    return m_remove.function();
  case NodeProperty::removeChild:
    return m_removeChild.function();
  case NodeProperty::insertBefore:
    return m_insertBefore.function();
  case NodeProperty::replaceChild:
    return m_replaceChild.function();
  default:
    break;
  }

  return nullptr;
}

JSValueRef JSNode::NodeInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getNodePropertyMap();

  if (propertyMap.count(name) == 0) {
    return JSEventTarget::EventTargetInstance::getProperty(name, exception);
  }

  auto property = propertyMap[name];

  switch (property) {
  case NodeProperty::isConnected:
    return JSValueMakeBoolean(_hostClass->ctx, isConnected());
  case NodeProperty::firstChild: {
    auto instance = firstChild();
    return instance != nullptr ? instance->object : JSValueMakeNull(ctx);
  }
  case NodeProperty::parentNode: {
    if (parentNode == nullptr) return JSValueMakeNull(ctx);
    return parentNode->object;
  }
  case NodeProperty::lastChild: {
    auto instance = lastChild();
    return instance != nullptr ? instance->object : JSValueMakeNull(ctx);
  }
  case NodeProperty::previousSibling: {
    auto instance = previousSibling();
    return instance != nullptr ? instance->object : JSValueMakeNull(ctx);
  }
  case NodeProperty::nextSibling: {
    auto instance = nextSibling();
    return instance != nullptr ? instance->object : JSValueMakeNull(ctx);
  }
  case NodeProperty::appendChild: {
    return prototype<JSNode>()->m_appendChild.function();
  }
  case NodeProperty::remove: {
    return prototype<JSNode>()->m_remove.function();
  }
  case NodeProperty::removeChild: {
    return prototype<JSNode>()->m_removeChild.function();
  }
  case NodeProperty::insertBefore: {
    return prototype<JSNode>()->m_insertBefore.function();
  }
  case NodeProperty::replaceChild: {
    return prototype<JSNode>()->m_replaceChild.function();
  }
  case NodeProperty::childNodes: {
    JSValueRef arguments[childNodes.size()];

    for (int i = 0; i < childNodes.size(); i++) {
      arguments[i] = childNodes[i]->object;
    }

    JSObjectRef array = JSObjectMakeArray(_hostClass->ctx, childNodes.size(), arguments, nullptr);
    return array;
  }
  case NodeProperty::nodeType:
    return JSValueMakeNumber(_hostClass->ctx, nodeType);
  case NodeProperty::textContent: {
    std::string textContent = internalGetTextContent();
    return JSValueMakeString(_hostClass->ctx, JSStringCreateWithUTF8CString(textContent.c_str()));
  }
  }

  return nullptr;
}

void JSNode::NodeInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getNodePropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    if (property == NodeProperty::textContent) {
      JSStringRef textContent = JSValueToStringCopy(_hostClass->ctx, value, exception);
      internalSetTextContent(textContent, exception);
    }
  } else {
    JSEventTarget::EventTargetInstance::setProperty(name, value, exception);
  }
}

void JSNode::NodeInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventTargetInstance::getPropertyNames(accumulator);

  for (auto &property : getNodePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::string JSNode::NodeInstance::internalGetTextContent() {
  return "";
}

void JSNode::NodeInstance::refer() {
  if (_referenceCount == 0) {
    JSValueProtect(_hostClass->ctx, this->object);
  }
  _referenceCount++;
}

void JSNode::NodeInstance::unrefer() {
  _referenceCount--;
  if (_referenceCount == 0 && context->isValid()) {
    JSValueUnprotect(_hostClass->ctx, this->object);
  }
}

void JSNode::NodeInstance::_notifyNodeRemoved(JSNode::NodeInstance *node) {}
void JSNode::NodeInstance::_notifyNodeInsert(JSNode::NodeInstance *node) {}
void JSNode::NodeInstance::internalSetTextContent(JSStringRef content, JSValueRef *exception) {}

} // namespace kraken::binding::jsc
