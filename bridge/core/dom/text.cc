/*
* Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "text.h"

namespace kraken {

Text* Text::Create(Document& document, const AtomicString& value) {
  return MakeGarbageCollected<Text>(document, value, ConstructionType::kCreateText);
}

Node::NodeType Text::getNodeType() const {
  return Node::kTextNode;
}

std::string Text::nodeName() const {
  return "#text";
}

Node* Text::Clone(Document& document, CloneChildrenFlag flag) const {
  return Create(document, data());
}

}
