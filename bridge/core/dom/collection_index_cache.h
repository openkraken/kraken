/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_COLLECTION_INDEX_CACHE_H_
#define KRAKENBRIDGE_CORE_DOM_COLLECTION_INDEX_CACHE_H_

#include <assert.h>
#include <climits>
#include "bindings/qjs/gc_visitor.h"
#include "foundation/macros.h"

namespace kraken {

template <typename Collection, typename NodeType>
class CollectionIndexCache {
  KRAKEN_DISALLOW_NEW();

 public:
  CollectionIndexCache();

  bool IsEmpty(const Collection& collection) {
    if (IsCachedNodeCountValid())
      return !CachedNodeCount();
    if (CachedNode())
      return false;
    return !NodeAt(collection, 0);
  }

  bool HasExactlyOneNode(const Collection& collection) {
    if (IsCachedNodeCountValid())
      return CachedNodeCount() == 1;
    if (CachedNode())
      return !CachedNodeIndex() && !NodeAt(collection, 1);
    return NodeAt(collection, 0) && !NodeAt(collection, 1);
  }

  unsigned NodeCount(const Collection&);
  NodeType* NodeAt(const Collection&, unsigned index);

  void Invalidate();

  void NodeInserted();
  void NodeRemoved();

  virtual void Trace(GCVisitor* visitor) const { visitor->Trace(current_node_); }

 protected:
  FORCE_INLINE NodeType* CachedNode() const { return current_node_; }
  FORCE_INLINE unsigned CachedNodeIndex() const {
    assert(CachedNode());
    return cached_node_index_;
  }
  FORCE_INLINE void SetCachedNode(NodeType* node, unsigned index) {
    assert(node);
    current_node_ = node;
    cached_node_index_ = index;
  }

  FORCE_INLINE bool IsCachedNodeCountValid() const { return is_length_cache_valid_; }
  FORCE_INLINE unsigned CachedNodeCount() const { return cached_node_count_; }
  FORCE_INLINE void SetCachedNodeCount(unsigned length) {
    cached_node_count_ = length;
    is_length_cache_valid_ = true;
  }

 private:
  NodeType* NodeBeforeCachedNode(const Collection&, unsigned index);
  NodeType* NodeAfterCachedNode(const Collection&, unsigned index);

  NodeType* current_node_;
  unsigned cached_node_count_;
  unsigned cached_node_index_ : 31;
  unsigned is_length_cache_valid_ : 1;
};

template <typename Collection, typename NodeType>
CollectionIndexCache<Collection, NodeType>::CollectionIndexCache()
    : current_node_(nullptr), cached_node_count_(0), cached_node_index_(0), is_length_cache_valid_(false) {}

template <typename Collection, typename NodeType>
void CollectionIndexCache<Collection, NodeType>::Invalidate() {
  current_node_ = nullptr;
  is_length_cache_valid_ = false;
}

template <typename Collection, typename NodeType>
void CollectionIndexCache<Collection, NodeType>::NodeInserted() {
  cached_node_count_++;
  current_node_ = nullptr;
}

template <typename Collection, typename NodeType>
void CollectionIndexCache<Collection, NodeType>::NodeRemoved() {
  cached_node_count_--;
  current_node_ = nullptr;
}

template <typename Collection, typename NodeType>
inline unsigned CollectionIndexCache<Collection, NodeType>::NodeCount(const Collection& collection) {
  if (IsCachedNodeCountValid())
    return CachedNodeCount();

  NodeAt(collection, UINT_MAX);
  assert(IsCachedNodeCountValid());

  return CachedNodeCount();
}

template <typename Collection, typename NodeType>
inline NodeType* CollectionIndexCache<Collection, NodeType>::NodeAt(const Collection& collection, unsigned index) {
  if (IsCachedNodeCountValid() && index >= CachedNodeCount())
    return nullptr;

  if (CachedNode()) {
    if (index > CachedNodeIndex())
      return NodeAfterCachedNode(collection, index);
    if (index < CachedNodeIndex())
      return NodeBeforeCachedNode(collection, index);
    return CachedNode();
  }

  // No valid cache yet, let's find the first matching element.
  NodeType* first_node = collection.TraverseToFirst();
  if (!first_node) {
    // The collection is empty.
    SetCachedNodeCount(0);
    return nullptr;
  }
  SetCachedNode(first_node, 0);
  return index ? NodeAfterCachedNode(collection, index) : first_node;
}

template <typename Collection, typename NodeType>
inline NodeType* CollectionIndexCache<Collection, NodeType>::NodeBeforeCachedNode(const Collection& collection,
                                                                                  unsigned index) {
  assert(CachedNode());  // Cache should be valid.
  unsigned current_index = CachedNodeIndex();
  assert(current_index > index);

  // Determine if we should traverse from the beginning of the collection
  // instead of the cached node.
  bool first_is_closer = index < current_index - index;
  if (first_is_closer || !collection.CanTraverseBackward()) {
    NodeType* first_node = collection.TraverseToFirst();
    assert(first_node);
    SetCachedNode(first_node, 0);
    return index ? NodeAfterCachedNode(collection, index) : first_node;
  }

  // Backward traversal from the cached node to the requested index.
  assert(collection.CanTraverseBackward());
  NodeType* current_node = collection.TraverseBackwardToOffset(index, *CachedNode(), current_index);
  assert(current_node);
  SetCachedNode(current_node, current_index);
  return current_node;
}

template <typename Collection, typename NodeType>
inline NodeType* CollectionIndexCache<Collection, NodeType>::NodeAfterCachedNode(const Collection& collection,
                                                                                 unsigned index) {
  assert(CachedNode());  // Cache should be valid.
  unsigned current_index = CachedNodeIndex();
  assert(current_index < index);

  // Determine if we should traverse from the end of the collection instead of
  // the cached node.
  bool last_is_closer = IsCachedNodeCountValid() && CachedNodeCount() - index < index - current_index;
  if (last_is_closer && collection.CanTraverseBackward()) {
    NodeType* last_item = collection.TraverseToLast();
    assert(last_item);
    SetCachedNode(last_item, CachedNodeCount() - 1);
    if (index < CachedNodeCount() - 1)
      return NodeBeforeCachedNode(collection, index);
    return last_item;
  }

  // Forward traversal from the cached node to the requested index.
  NodeType* current_node = collection.TraverseForwardToOffset(index, *CachedNode(), current_index);
  if (!current_node) {
    // Did not find the node. On plus side, we now know the length.
    if (IsCachedNodeCountValid())
      assert(current_index + 1 == CachedNodeCount());
    SetCachedNodeCount(current_index + 1);
    return nullptr;
  }
  SetCachedNode(current_node, current_index);
  return current_node;
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_COLLECTION_INDEX_CACHE_H_
