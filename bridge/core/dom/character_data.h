/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CHARACTER_DATA_H
#define KRAKENBRIDGE_CHARACTER_DATA_H

#include "node.h"

namespace kraken {

class Document;

class CharacterData : public Node {
  DEFINE_WRAPPERTYPEINFO();

 public:
  const AtomicString& data() const { return data_; }
  int64_t length() const { return data_.length(); };
  void setData(const AtomicString& data);

  std::string nodeValue() const override;

 protected:
  CharacterData(TreeScope& tree_scope, const AtomicString& text, ConstructionType type);

 private:
  AtomicString data_;
};

template <>
struct DowncastTraits<CharacterData> {
  static bool AllowFrom(const Node& node) { return node.IsCharacterDataNode(); }
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CHARACTER_DATA_H
