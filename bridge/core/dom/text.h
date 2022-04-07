/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_TEXT_H_
#define KRAKENBRIDGE_CORE_DOM_TEXT_H_

#include "character_data.h"

namespace kraken {

class Text : public CharacterData {
  DEFINE_WRAPPERTYPEINFO();
 public:
  static const unsigned kDefaultLengthLimit = 1 << 16;

  static Text* Create(Document&, const AtomicString&);

  Text(Document& document, const AtomicString& data, ConstructionType type) : CharacterData(document, data, type) {}

  NodeType getNodeType() const override;

 private:
  std::string nodeName() const override;
  Node* Clone(Document&, CloneChildrenFlag) const override;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_TEXT_H_
