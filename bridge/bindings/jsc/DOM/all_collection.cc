/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "all_collection.h"

namespace kraken::binding::jsc {

JSValueRef JSAllCollection::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getAllCollectionPropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch(property) {
    case AllCollectionProperty::add:
    case AllCollectionProperty::item:
    case AllCollectionProperty::remove:
      return nullptr;
    case AllCollectionProperty::length:
      return JSValueMakeNumber(ctx, m_nodes.size());
    }
  }

  return HostObject::getProperty(name, exception);
}

JSValueRef JSAllCollection::item(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    return nullptr;
  }

  size_t index = JSValueToNumber(ctx, arguments[0], exception);
  auto collection = reinterpret_cast<JSAllCollection *>(JSObjectGetPrivate(function));

  if (index >= collection->m_nodes.size()) {
    return nullptr;
  }

  auto node = collection->m_nodes[index];
  return node->object;
}

JSValueRef JSAllCollection::add(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to execute add() on HTMLAllCollection: 1 arguments required.", exception);
    return nullptr;
  }

  if (!JSValueIsObject(ctx, arguments[0])) {
    throwJSError(ctx, "Failed to execute add() on HTMLAllCollection: first arguments should be a object.",
                    exception);
    return nullptr;
  }

  JSObjectRef nodeRef = JSValueToObject(ctx, arguments[0], exception);
  JSObjectRef beforeRef = nullptr;

  if (argumentCount == 2 && JSValueIsObject(ctx, arguments[1])) {
    beforeRef = JSValueToObject(ctx, arguments[1], exception);
  }

  auto nodeInstance = reinterpret_cast<NodeInstance *>(JSObjectGetPrivate(nodeRef));
  auto collection = reinterpret_cast<JSAllCollection *>(JSObjectGetPrivate(function));
  NodeInstance *beforeInstance = nullptr;

  if (beforeRef != nullptr) {
    beforeInstance = reinterpret_cast<NodeInstance *>(JSObjectGetPrivate(nodeRef));
  }

  collection->internalAdd(nodeInstance, beforeInstance);

  return nullptr;
}

JSValueRef JSAllCollection::remove(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to execute remove() on HTMLAllCollection: 1 arguments required.", exception);
    return nullptr;
  }

  size_t index = JSValueToNumber(ctx, arguments[0], exception);
  auto collection = reinterpret_cast<JSAllCollection *>(JSObjectGetPrivate(function));

  collection->m_nodes.erase(collection->m_nodes.begin() + index);

  return nullptr;
}

void JSAllCollection::internalAdd(NodeInstance *node, NodeInstance *before) {
  if (before != nullptr) {
    auto it = std::find(m_nodes.begin(), m_nodes.end(), before);
    m_nodes.erase(it);
    m_nodes.insert(it, node);
  } else {
    m_nodes.emplace_back(node);
  }
}

void JSAllCollection::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  HostObject::getPropertyNames(accumulator);

  for (auto &property : getAllCollectionPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
