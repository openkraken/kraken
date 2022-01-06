/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_DOM_COLLECTION_INDEX_CACHE_H_
#define KRAKENBRIDGE_BINDINGS_QJS_DOM_COLLECTION_INDEX_CACHE_H_

#include "include/kraken_foundation.h"

namespace kraken::binding::qjs {

template <typename Collection, typename NodeType>
class CollectionIndexCache {
 public:
  bool isEmpty(const Collection& collection) {
    if (isCachedNodeCountValid())
      return !cachedNodeCount();
    if (cachedNode())
      return false;
    return !nodeAt(collection, 0);
  }
  bool HasExactlyOneNode(const Collection& collection) {
    if (isCachedNodeCountValid())
      return cachedNodeCount() == 1;
    if (cachedNode())
      return !cachedNodeIndex() && !nodeAt(collection, 1);
    return nodeAt(collection, 0) && !nodeAt(collection, 1);
  }

  uint32_t nodeCount(const Collection&);
  NodeType* nodeAt(const Collection&, uint32_t index);

  void invalidate();

  void nodeInserted();
  void nodeRemoved();

 protected:
  FORCE_INLINE NodeType* cachedNode() const { return current_node_; }
  FORCE_INLINE unsigned cachedNodeIndex() const {
    assert(cachedNode() != nullptr);
    return cached_node_index_;
  }
  FORCE_INLINE void setCachedNode(NodeType* node, unsigned index) {
    assert(node != nullptr);
    current_node_ = node;
    cached_node_index_ = index;
  }
  FORCE_INLINE bool isCachedNodeCountValid() const {
    return is_length_cache_valid_;
  }
  FORCE_INLINE unsigned cachedNodeCount() const { return cached_node_count_; }
  FORCE_INLINE void setCachedNodeCount(unsigned length) {
    cached_node_count_ = length;
    is_length_cache_valid_ = true;
  }
 private:
  NodeType* nodeBeforeCachedNode(const Collection&, unsigned index);
  NodeType* nodeAfterCachedNode(const Collection&, unsigned index);

  NodeType* current_node_{nullptr};
  unsigned cached_node_count_;
  unsigned cached_node_index_ : 31;
  unsigned is_length_cache_valid_ : 1;
};

template<typename Collection, typename NodeType>
void CollectionIndexCache<Collection, NodeType>::invalidate() {
  current_node_ = nullptr;
  is_length_cache_valid_ = false;
}

template<typename Collection, typename NodeType>
void CollectionIndexCache<Collection, NodeType>::nodeInserted() {
  cached_node_count_++;
  current_node_ = nullptr;
}

template<typename Collection, typename NodeType>
void CollectionIndexCache<Collection, NodeType>::nodeRemoved() {
  cached_node_count_--;
  current_node_ = nullptr;
}

template<typename Collection, typename NodeType>
inline uint32_t CollectionIndexCache<Collection, NodeType>::nodeCount(const Collection& collection) {
  if (isCachedNodeCountValid())
    return cachedNodeCount();

  nodeAt(collection, UINT_MAX);
  assert(isCachedNodeCountValid());

  return cachedNodeCount();
}

template<typename Collection, typename NodeType>
inline NodeType *CollectionIndexCache<Collection, NodeType>::nodeAt(const Collection& collection, uint32_t index) {
  if (isCachedNodeCountValid() && index >= cachedNodeCount())
    return nullptr;

  if (cachedNode()) {
    if (index > cachedNodeIndex())
      return nodeAfterCachedNode(collection, index);
    if (index < cachedNodeIndex())
      return nodeBeforeCachedNode(collection, index);
    return cachedNode();
  }

  // No valid cache yet, let's find the first matching element.
  NodeType* first_node = collection.traverseToFirst();
  if (!first_node) {
    // The collection is empty.
    setCachedNodeCount(0);
    return nullptr;
  }
  setCachedNode(first_node, 0);
  return index ? nodeAfterCachedNode(collection, index) : first_node;
}


template<typename Collection, typename NodeType>
NodeType *CollectionIndexCache<Collection, NodeType>::nodeBeforeCachedNode(const Collection& collection, unsigned int index) {
  assert(cachedNode() != nullptr);  // Cache should be valid.
  unsigned current_index = cachedNodeIndex();
  assert(current_index > index);

  // Determine if we should traverse from the beginning of the collection
  // instead of the cached node.
  bool first_is_closer = index < current_index - index;
  if (first_is_closer || !collection.canTraverseBackward()) {
    NodeType* first_node = collection.traverseToFirst();
    assert(first_node != nullptr);
    setCachedNode(first_node, 0);
    return index ? nodeAfterCachedNode(collection, index) : first_node;
  }

  // Backward traversal from the cached node to the requested index.
  assert(collection.canTraverseBackward());
  NodeType* current_node =
      collection.traverseBackwardToOffset(index, *cachedNode(), current_index);
  assert(current_node != nullptr);
  setCachedNode(current_node, current_index);
  return current_node;
}


template<typename Collection, typename NodeType>
NodeType *CollectionIndexCache<Collection, NodeType>::nodeAfterCachedNode(const Collection& collection, unsigned int index) {
  assert(cachedNode() != nullptr);  // Cache should be valid.
  unsigned current_index = cachedNodeIndex();
  assert(current_index < index);

  // Determine if we should traverse from the end of the collection instead of
  // the cached node.
  bool last_is_closer = isCachedNodeCountValid() &&
      cachedNodeCount() - index < index - current_index;
  if (last_is_closer && collection.canTraverseBackward()) {
    NodeType* last_item = collection.traverseToLast();
    assert(last_item != nullptr);
    setCachedNode(last_item, cachedNodeCount() - 1);
    if (index < cachedNodeCount() - 1)
      return nodeBeforeCachedNode(collection, index);
    return last_item;
  }

  // Forward traversal from the cached node to the requested index.
  NodeType* current_node =
      collection.traverseForwardToOffset(index, *cachedNode(), current_index);
  if (!current_node) {
    // Did not find the node. On plus side, we now know the length.
    if (isCachedNodeCountValid())
      assert(current_index + 1 == cachedNodeCount());
    setCachedNodeCount(current_index + 1);
    return nullptr;
  }
  setCachedNode(current_node, current_index);
  return current_node;
}


}

#endif //KRAKENBRIDGE_BINDINGS_QJS_DOM_COLLECTION_INDEX_CACHE_H_
