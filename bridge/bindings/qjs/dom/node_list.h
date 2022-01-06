/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_DOM_NODE_LIST_H_
#define KRAKENBRIDGE_BINDINGS_QJS_DOM_NODE_LIST_H_

#include "bindings/qjs/garbage_collected.h"
#include "collection_index_cache.h"
#include "node.h"

namespace kraken::binding::qjs {

class NodeList : public GarbageCollected<NodeList> {
 public:
  NodeList() = delete;
  explicit NodeList(NodeInstance* parent);

  // DOM methods & attributes for NodeList
  uint32_t length() { return m_collection_index_cache.nodeCount(*this); };
  NodeInstance* item(unsigned index);

  NodeInstance& ownerNode() const { return *m_parentNode; }
  NodeInstance& rootNode() const { return ownerNode(); }

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;

  // CollectionIndexCache API.
  bool canTraverseBackward() const { return true; }
  NodeInstance* traverseToFirst() const { return rootNode().firstChild(); }
  NodeInstance* traverseToLast() const { return rootNode().lastChild(); }
  NodeInstance* traverseForwardToOffset(unsigned offset, NodeInstance& current_node, unsigned& current_offset) const;
  NodeInstance* traverseBackwardToOffset(unsigned offset, NodeInstance& current_node, unsigned& current_offset) const;

 private:
  NodeInstance* m_parentNode{nullptr};
  CollectionIndexCache<NodeList, NodeInstance> m_collection_index_cache;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_BINDINGS_QJS_DOM_NODE_LIST_H_
