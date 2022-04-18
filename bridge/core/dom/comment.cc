/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "comment.h"
#include "built_in_string.h"

namespace kraken {

Comment* Comment::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<Comment>(*context->document(), ConstructionType::kCreateOther);
}

Comment* Comment::Create(Document& document) {
  return MakeGarbageCollected<Comment>(document, ConstructionType::kCreateOther);
}

Comment::Comment(Document& document, ConstructionType type)
    : CharacterData(document, built_in_string::kempty_string, type) {}

Node::NodeType Comment::nodeType() const {
  return Node::kCommentNode;
}
std::string Comment::nodeName() const {
  return "#comment";
}

Node* Comment::Clone(Document& factory, CloneChildrenFlag flag) const {
  return Create(factory);
}

}  // namespace kraken
