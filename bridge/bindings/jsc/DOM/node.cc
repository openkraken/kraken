/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "node.h"
#include "bindings/jsc/macros.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

JSNode::JSNode(JSContext *context) : JSEventTarget(context, "Node") {}
JSNode::JSNode(JSContext *context, const char *name) : JSEventTarget(context, name) {}

JSNode::NodeInstance::~NodeInstance() {
  // Release propertyNames;
  for (auto &propertyName : propertyNames) {
    JSStringRelease(propertyName);
  }

  // The this node is finalized, should tell all children this parent will no longer protecting them.
  for (auto &node : childNodes) {
    node->parentNode = nullptr;
    JSValueUnprotect(_hostClass->ctx, node->object);
  }
}

JSNode::NodeInstance::NodeInstance(JSNode *node, NodeType nodeType) : EventTargetInstance(node), nodeType(nodeType) {}

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

  auto parentChildNodes = parentNode->childNodes;
  auto it = std::find(parentChildNodes.begin(), parentChildNodes.end(), this);

  if (it != parentChildNodes.end()) {
    return *(it--);
  }

  return nullptr;
}

JSNode::NodeInstance *JSNode::NodeInstance::nextSibling() {
  if (parentNode == nullptr) return nullptr;

  auto parentChildNodes = parentNode->childNodes;
  auto it = std::find(parentChildNodes.begin(), parentChildNodes.end(), this);

  if (it != parentChildNodes.end()) {
    return *(it++);
  }

  return nullptr;
}

void JSNode::NodeInstance::ensureDetached(JSNode::NodeInstance *node) {
  if (node->parentNode != nullptr) {
    auto it = std::find(node->parentNode->childNodes.begin(), node->parentNode->childNodes.end(), node);
    if (it != node->parentNode->childNodes.end()) {
      // TODO: child._notifyNodeRemoved(child.parentNode);
      node->parentNode->childNodes.erase(it);
      node->parentNode = nullptr;
      JSValueUnprotect(_hostClass->ctx, node->object);
    }
  }
}

JSValueRef JSNode::NodeInstance::appendChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                             size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'appendChild' on 'Node': first argument is required.", exception);
    return nullptr;
  }

  auto selfInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(function));
  const JSValueRef nodeValueRef = arguments[0];

  if (!JSValueIsObject(ctx, nodeValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.",
                    exception);
    return nullptr;
  }

  JSObjectRef nodeObjectRef = JSValueToObject(ctx, nodeValueRef, exception);
  auto nodeInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(nodeObjectRef));

  if (nodeInstance == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'appendChild' on 'Node': first arguments should be an Node type.",
                    exception);
    return nullptr;
  }

  if (nodeInstance->eventTargetId == BODY_TARGET_ID || nodeInstance == selfInstance) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'appendChild' on 'Node': The new child element contains the parent.",
                    exception);
    return nullptr;
  }

  selfInstance->internalAppendChild(nodeInstance);

  return nullptr;
}

JSValueRef JSNode::NodeInstance::insertBefore(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                              size_t argumentCount, const JSValueRef *arguments,
                                              JSValueRef *exception) {
  const JSValueRef nodeValueRef = arguments[0];
  const JSValueRef referenceNodeValueRef = arguments[1];

  if (!JSValueIsObject(ctx, nodeValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'insertBefore' on 'Node': the node element is not object.", exception);
    return nullptr;
  }

  JSObjectRef nodeObjectRef = JSValueToObject(ctx, nodeValueRef, exception);

  if (!JSValueIsObject(ctx, referenceNodeValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'insertBefore' on 'Node': the reference node element is not object.",
                    exception);
    return nullptr;
  }

  JSObjectRef referenceNodeObjectRef = JSValueToObject(ctx, referenceNodeValueRef, exception);

  auto selfInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(function));

  auto nodeInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(nodeObjectRef));
  auto referenceInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(referenceNodeObjectRef));

  selfInstance->internalInsertBefore(nodeInstance, referenceInstance);

  return nullptr;
}

JSValueRef JSNode::NodeInstance::replaceChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                              size_t argumentCount, const JSValueRef *arguments,
                                              JSValueRef *exception) {

  if (argumentCount < 2) {
    JSC_THROW_ERROR(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 2 arguments required",
                    exception);
    return nullptr;
  }

  const JSValueRef newChildValueRef = arguments[0];
  const JSValueRef oldChildValueRef = arguments[1];

  if (!JSValueIsObject(ctx, newChildValueRef)) {
    JSC_THROW_ERROR(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 1 arguments is not object",
                    exception);
    return nullptr;
  }

  JSObjectRef newChildObjectRef = JSValueToObject(ctx, newChildValueRef, exception);

  if (!JSValueIsObject(ctx, oldChildValueRef)) {
    JSC_THROW_ERROR(ctx, "Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 2 arguments is not object.",
                    exception);
    return nullptr;
  }

  JSObjectRef oldChildObjectRef = JSValueToObject(ctx, oldChildValueRef, exception);

  auto selfInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(function));
  auto newChildInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(newChildObjectRef));
  auto oldChildInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(oldChildObjectRef));

  if (oldChildInstance == nullptr || oldChildInstance->parentNode == nullptr) {
    JSC_THROW_ERROR(ctx,
                    "Failed to execute 'replaceChild' on 'Node': The node to be replaced is not a child of this node.",
                    exception);
    return nullptr;
  }

  selfInstance->internalReplaceChild(newChildInstance, oldChildInstance);

  return nullptr;
}

void JSNode::NodeInstance::internalInsertBefore(JSNode::NodeInstance *node, JSNode::NodeInstance *referenceNode) {
  if (referenceNode == nullptr) {
    internalAppendChild(node);
  } else {
    ensureDetached(node);
    auto parent = referenceNode->parentNode;
    if (parent != nullptr) {
      auto parentChildNodes = parent->childNodes;
      auto it = std::find(parentChildNodes.begin(), parentChildNodes.end(), referenceNode);
      parentChildNodes.insert(it, node);
      node->parentNode = parent;
      JSValueProtect(_hostClass->ctx, node->object);
      // TODO: newChild._notifyNodeInsert(parentNode);

      NativeString *nodeTargetId;
      NativeString *position;
      STD_STRING_TO_NATIVE_STRING(std::to_string(node->eventTargetId).c_str(), nodeTargetId);
      STD_STRING_TO_NATIVE_STRING("beforebegin", position);

      auto args = new NativeString *[2];
      args[0] = nodeTargetId->clone();
      args[1] = position->clone();

      foundation::UICommandTaskMessageQueue::instance(_hostClass->context->getContextId())
        ->registerCommand(referenceNode->eventTargetId, UICommandType::insertAdjacentNode, args, 2, nullptr);
    }
  }
}

JSValueRef JSNode::NodeInstance::remove(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto selfInstance = static_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(function));
  selfInstance->internalRemove(exception);
  return nullptr;
}

void JSNode::NodeInstance::internalAppendChild(JSNode::NodeInstance *node) {
  ensureDetached(node);
  childNodes.emplace_back(node);
  node->parentNode = this;
  JSValueProtect(_hostClass->ctx, node->object);

  //  TODO: child._notifyNodeInsert(this);
  NativeString *childTargetId;
  STD_STRING_TO_NATIVE_STRING(std::to_string(node->eventTargetId).c_str(), childTargetId);

  NativeString *position;
  STD_STRING_TO_NATIVE_STRING("beforeend", position);
  auto args = new NativeString *[2];
  args[0] = childTargetId->clone();
  args[1] = position->clone();

  foundation::UICommandTaskMessageQueue::instance(node->_hostClass->context->getContextId())
    ->registerCommand(eventTargetId, UICommandType::insertAdjacentNode, args, 2, nullptr);
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
    JSValueUnprotect(_hostClass->ctx, node->object);
    // TODO: child._notifyNodeRemove(this);
    foundation::UICommandTaskMessageQueue::instance(node->_hostClass->context->getContextId())
      ->registerCommand(node->eventTargetId, UICommandType::removeNode, nullptr, 0, nullptr);
  } else {
    JSC_THROW_ERROR(_hostClass->ctx,
                    "Failed to execute 'removeChild' on 'Node': The node to be removed is not a child of this node.",
                    exception);
    return node;
  }

  return node;
}

JSNode::NodeInstance *JSNode::NodeInstance::internalReplaceChild(JSNode::NodeInstance *newChild,
                                                                 JSNode::NodeInstance *oldChild) {
  ensureDetached(newChild);
  auto parent = oldChild->parentNode;
  oldChild->parentNode = nullptr;
  JSValueUnprotect(_hostClass->ctx, oldChild->object);

  auto childIndex = std::find(parent->childNodes.begin(), parent->childNodes.end(), oldChild);
  newChild->parentNode = parent;
  parent->childNodes.erase(childIndex);
  parent->childNodes.insert(childIndex, newChild);
  JSValueProtect(_hostClass->ctx, newChild->object);

  //  TODO: oldChild._notifyNodeRemoved(parentNode);
  //  TODO: newChild._notifyNodeInsert(parentNode);

  NativeString *newChildTargetId;
  NativeString *position;
  STD_STRING_TO_NATIVE_STRING(std::to_string(newChild->eventTargetId).c_str(), newChildTargetId);
  STD_STRING_TO_NATIVE_STRING("afterend", position);
  auto args = new NativeString *[2];
  args[0] = newChildTargetId->clone();
  args[1] = position->clone();

  foundation::UICommandTaskMessageQueue::instance(_hostClass->context->getContextId())
    ->registerCommand(oldChild->eventTargetId, UICommandType::insertAdjacentNode, args, 2, nullptr);

  foundation::UICommandTaskMessageQueue::instance(_hostClass->context->getContextId())
    ->registerCommand(oldChild->eventTargetId, UICommandType::removeNode, nullptr, 0, nullptr);

  return oldChild;
}

JSValueRef JSNode::NodeInstance::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);

  if (name == "isConnected") {
    return JSValueMakeBoolean(_hostClass->ctx, isConnected());
  } else if (name == "firstChild") {
    auto instance = firstChild();
    return instance != nullptr ? instance->object : nullptr;
  } else if (name == "lastChild") {
    auto instance = lastChild();
    return instance != nullptr ? instance->object : nullptr;
  } else if (name == "previousSibling") {
    auto instance = previousSibling();
    return instance != nullptr ? instance->object : nullptr;
  } else if (name == "nextSibling") {
    auto instance = nextSibling();
    return instance != nullptr ? instance->object : nullptr;
  } else if (name == "appendChild") {
    return propertyBindingFunction(_hostClass->context, this, "appendChild", appendChild);
  } else if (name == "remove") {
    return propertyBindingFunction(_hostClass->context, this, "remove", remove);
  } else if (name == "insertBefore") {
    return propertyBindingFunction(_hostClass->context, this, "insertBefore", insertBefore);
  } else if (name == "replaceChild") {
    return propertyBindingFunction(_hostClass->context, this, "replaceChild", replaceChild);
  }
  return JSEventTarget::EventTargetInstance::getProperty(nameRef, exception);
}

void JSNode::NodeInstance::setProperty(JSStringRef nameRef, JSValueRef value, JSValueRef *exception) {
  JSEventTarget::EventTargetInstance::setProperty(nameRef, value, exception);
}

void JSNode::NodeInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventTargetInstance::getPropertyNames(accumulator);

  for (auto &property : propertyNames) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
