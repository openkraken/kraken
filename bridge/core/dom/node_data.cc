/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "node_data.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "container_node.h"
#include "ng/child_node_list.h"
#include "ng/empty_node_list.h"
#include "ng/node_list.h"

namespace kraken {

ChildNodeList* NodeData::GetChildNodeList(ContainerNode& node) {
  assert(!child_node_list_ || &node == child_node_list_->VirtualOwnerNode());
  return To<ChildNodeList>(child_node_list_.Get());
}

ChildNodeList* NodeData::EnsureChildNodeList(ContainerNode& node) {
  if (child_node_list_)
    return To<ChildNodeList>(child_node_list_.Get());
  auto* list = MakeGarbageCollected<ChildNodeList>(&node);
  child_node_list_.Initialize(list);
  return list;
}

EmptyNodeList* NodeData::EnsureEmptyChildNodeList(Node& node) {
  if (child_node_list_)
    return To<EmptyNodeList>(child_node_list_.Get());
  auto* list = MakeGarbageCollected<EmptyNodeList>(&node);
  child_node_list_.Initialize(list);
  return list;
}

void NodeData::Trace(GCVisitor* visitor) const {
  visitor->Trace(child_node_list_->ToQuickJSUnsafe());
}

}  // namespace kraken
