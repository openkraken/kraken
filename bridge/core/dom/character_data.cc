/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "character_data.h"

namespace kraken {

void CharacterData::setData(const AtomicString& data) {
  data_ = data;
}

std::string CharacterData::nodeValue() const {
  return data_.ToStdString();
}

}  // namespace kraken
