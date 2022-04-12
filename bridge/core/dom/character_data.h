/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CHARACTER_DATA_H
#define KRAKENBRIDGE_CHARACTER_DATA_H

#include "node.h"

namespace kraken {

class CharacterData : public Node {
  DEFINE_WRAPPERTYPEINFO();

 public:
  const AtomicString& data() const { return data_; }
  void setData(const AtomicString& data);

 protected:
  CharacterData(Document& tree_scope, const AtomicString& text, ConstructionType type)
      : Node(&tree_scope, type), data_(!text.IsNull() ? text : AtomicString::Empty(ctx())) {
    assert(type == kCreateOther || type == kCreateText);
  }

 private:
  AtomicString data_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CHARACTER_DATA_H
