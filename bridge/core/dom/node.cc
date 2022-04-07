/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "node.h"
#include "node_data.h"
#include "node_list.h"
#include "child_node_list.h"
#include "empty_node_list.h"

namespace kraken {

Node* Node::Create(ExecutingContext* context, ExceptionState& exception_state) {
  exception_state.ThrowException(context->ctx(), ErrorType::TypeError, "Illegal constructor");
}

ContainerNode* Node::parentNode() const {
  return ParentOrShadowHostNode();
}

NodeList* Node::childNodes() {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node)
    return EnsureData().EnsureChildNodeList(*this_node);
  return EnsureData().EnsureEmptyChildNodeList(*this);
}

NodeData& Node::CreateData() {
  data_ = std::make_unique<NodeData>();
  return *Data();
}

NodeData& Node::EnsureData() {
  if (HasData())
    return *Data();
  return CreateData();
}

void Node::Trace(GCVisitor*) const {}

}  // namespace kraken
