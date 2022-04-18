/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "character_data.h"
#include "core/dom/document.h"

namespace kraken {

void CharacterData::setData(const AtomicString& data) {
  data_ = data;
}

std::string CharacterData::nodeValue() const {
  return data_.ToStdString();
}
CharacterData::CharacterData(Document& document, const AtomicString& text, Node::ConstructionType type)
    : Node(document.GetExecutingContext(), &document, type), data_(!text.IsNull() ? text : AtomicString::Empty(ctx())) {
  assert(type == kCreateOther || type == kCreateText);
}

}  // namespace kraken
