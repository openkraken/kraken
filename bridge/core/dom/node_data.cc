/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "node_data.h"
#include "bindings/qjs/garbage_collected.h"
#include "ng/child_node_list.h"
#include "ng/empty_node_list.h"
#include "container_node.h"

namespace kraken {

ChildNodeList* NodeData::GetChildNodeList(ContainerNode& node) {
  assert(!child_node_list_ || &node == child_node_list_->VirtualOwnerNode());
  return To<ChildNodeList>(child_node_list_);
}

ChildNodeList* NodeData::EnsureChildNodeList(ContainerNode& node) {
  if (child_node_list_)
    return To<ChildNodeList>(child_node_list_);
  auto* list = MakeGarbageCollected<ChildNodeList>(&node);
  child_node_list_ = list;
  return list;
}

EmptyNodeList* NodeData::EnsureEmptyChildNodeList(Node& node) {
  if (child_node_list_)
    return To<EmptyNodeList>(child_node_list_);
  auto* list = MakeGarbageCollected<EmptyNodeList>(&node);
  child_node_list_ = list;
  return list;
}

void NodeData::Trace(GCVisitor* visitor) const {
  child_node_list_->Trace(visitor);
}

}  // namespace kraken
