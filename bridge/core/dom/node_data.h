/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_NODE_DATA_H_
#define KRAKENBRIDGE_CORE_DOM_NODE_DATA_H_

#include <cinttypes>
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace kraken {

class ChildNodeList;
class EmptyNodeList;
class ContainerNode;
class NodeList;
class Node;

class NodeData {
 public:
  enum class ClassType : uint8_t {
    kNodeRareData,
    kElementRareData,
  };

  ChildNodeList* GetChildNodeList(ContainerNode& node);

  ChildNodeList* EnsureChildNodeList(ContainerNode& node);

  EmptyNodeList* EnsureEmptyChildNodeList(Node& node);

  void Trace(GCVisitor* visitor) const;

 private:
  NodeList* child_node_list_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_NODE_DATA_H_
