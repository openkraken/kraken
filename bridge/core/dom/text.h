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
  static Text* Create(ExecutingContext* context, ExceptionState& executing_context);
  static Text* Create(ExecutingContext* context, const AtomicString& value, ExceptionState& executing_context);

  Text(TreeScope& tree_scope, const AtomicString& data, ConstructionType type)
      : CharacterData(tree_scope, data, type) {}

  NodeType nodeType() const override;

 private:
  std::string nodeName() const override;
  Node* Clone(Document&, CloneChildrenFlag) const override;
};

template <>
struct DowncastTraits<Text> {
  static bool AllowFrom(const Node& node) { return node.IsTextNode(); };
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_TEXT_H_
