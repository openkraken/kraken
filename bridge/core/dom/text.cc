/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "text.h"

namespace kraken {

Text* Text::Create(Document& document, const AtomicString& value) {
  return MakeGarbageCollected<Text>(document, value, ConstructionType::kCreateText);
}

Text* Text::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<Text>(*context->document(), AtomicString::Empty(context->ctx()),
                                    ConstructionType::kCreateText);
}

Text* Text::Create(ExecutingContext* context, const AtomicString& value, ExceptionState& executing_context) {
  return MakeGarbageCollected<Text>(*context->document(), value, ConstructionType::kCreateText);
}

Node::NodeType Text::nodeType() const {
  return Node::kTextNode;
}

std::string Text::nodeName() const {
  return "#text";
}

Node* Text::Clone(Document& document, CloneChildrenFlag flag) const {
  return Create(document, data());
}

}  // namespace kraken
