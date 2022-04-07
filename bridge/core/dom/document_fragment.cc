/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document_fragment.h"
#include "events/event_target.h"

namespace kraken {

DocumentFragment* DocumentFragment::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return nullptr;
}

DocumentFragment::DocumentFragment(ExecutingContext* context): ContainerNode(context, ConstructionType::kCreateDocumentFragment) {}

std::string DocumentFragment::nodeName() const {
  return "#document-fragment";
}

Node::NodeType DocumentFragment::getNodeType() const {
  return NodeType::kDocumentFragmentNode;
}

bool DocumentFragment::ChildTypeAllowed(NodeType type) const {
  switch (type) {
    case kElementNode:
    case kCommentNode:
    case kTextNode:
      return true;
    default:
      return false;
  }
}

}  // namespace kraken
