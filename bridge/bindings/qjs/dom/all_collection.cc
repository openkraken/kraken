/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "all_collection.h"

namespace kraken::binding::qjs {

JSValue AllCollection::item(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_NULL;
  }

  uint32_t index;
  JS_ToUint32(ctx, &index, argv[0]);
  auto* collection = static_cast<AllCollection*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));

  if (index >= collection->m_nodes.size()) {
    return JS_NULL;
  }

  auto node = collection->m_nodes[index];
  return node->jsObject;
}
JSValue AllCollection::add(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute add() on HTMLAllCollection: 1 arguments required.");
  }

  if (!JS_IsObject(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute add() on HTMLAllCollection: first arguments should be a object.");
  }

  JSValue before = JS_NULL;

  if (argc == 2 && JS_IsObject(argv[1])) {
    before = argv[1];
  }

  auto* node = static_cast<NodeInstance*>(JS_GetOpaque(argv[0], JSContext::kHostObjectClassId));
  auto* collection = static_cast<AllCollection*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  NodeInstance* beforeNode = nullptr;

  if (!JS_IsNull(before)) {
    beforeNode = static_cast<NodeInstance*>(JS_GetOpaque(before, JSContext::kHostObjectClassId));
  }

  collection->internalAdd(node, beforeNode);

  return JS_NULL;
}
JSValue AllCollection::remove(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute remove() on HTMLAllCollection: 1 arguments required.");
  }

  uint32_t index;
  JS_ToUint32(ctx, &index, argv[0]);
  auto* collection = static_cast<AllCollection*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  collection->m_nodes.erase(collection->m_nodes.begin() + index);
  return JS_NULL;
}
void AllCollection::internalAdd(NodeInstance* node, NodeInstance* before) {
  if (before != nullptr) {
    auto it = std::find(m_nodes.begin(), m_nodes.end(), before);
    m_nodes.erase(it);
    m_nodes.insert(it, node);
  } else {
    m_nodes.emplace_back(node);
  }
}

IMPL_PROPERTY_GETTER(AllCollection, length)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* collection = static_cast<AllCollection*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewUint32(ctx, collection->m_nodes.size());
}

}  // namespace kraken::binding::qjs
