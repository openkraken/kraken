/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_ELEMENT_DATA_H_
#define KRAKENBRIDGE_CORE_DOM_ELEMENT_DATA_H_

#include "bindings/qjs/atomic_string.h"
#include "attribute_collection.h"
#include "foundation/casting.h"

namespace kraken {

class UniqueElementData;

// ElementData represents very common, but not necessarily unique to an element,
// data such as attributes, inline style, and parsed class names and ids.
class ElementData {
 public:
  AttributeCollection Attributes() const;

  ~ElementData();

  bool IsEquivalent(const ElementData* other) const;

 protected:
  uint32_t array_size;

 private:
  std::shared_ptr<UniqueElementData> MakeUniqueCopy() const;

  //  mutable Member<CSSPropertyValueSet> inline_style_;
  //  mutable SpaceSplitString class_names_;
  //  mutable AtomicString id_for_style_resolution_;
};

// SharableElementData is managed by ElementDataCache and is produced by
// the parser during page load for elements that have identical attributes. This
// is a memory optimization since it's very common for many elements to have
// duplicate sets of attributes (ex. the same classes).
class ShareableElementData final : public ElementData {
 public:
  static ShareableElementData* CreateWithAttributes(const std::vector<Attribute>&);

  explicit ShareableElementData(const std::vector<Attribute>&);
  explicit ShareableElementData(const UniqueElementData&);
  ~ShareableElementData();

  AttributeCollection Attributes() const;

  Attribute attribute_array_[0];
};

// UniqueElementData is created when an element needs to mutate its attributes
// or gains presentation attribute style (ex. width="10"). It does not need to
// be created to fill in values in the ElementData that are derived from
// attributes. For example populating the inline_style_ from the style attribute
// doesn't require a UniqueElementData as all elements with the same style
// attribute will have the same inline style.
class UniqueElementData final : public ElementData {
 public:
  ShareableElementData* MakeShareableCopy() const;

  MutableAttributeCollection Attributes();
  AttributeCollection Attributes() const;

  UniqueElementData();
  explicit UniqueElementData(const ShareableElementData&);
  explicit UniqueElementData(const UniqueElementData&);

  AttributeVector attribute_vector_;
};

inline AttributeCollection ElementData::Attributes() const {
  if (auto* unique_element_data = DynamicTo<UniqueElementData>(this))
    return unique_element_data->Attributes();
  return To<ShareableElementData>(this)->Attributes();
}

inline AttributeCollection ShareableElementData::Attributes() const {
  return AttributeCollection(attribute_array_, array_size);
}

inline AttributeCollection UniqueElementData::Attributes() const {
  return AttributeCollection(attribute_vector_.data(),
                             attribute_vector_.size());
}

inline MutableAttributeCollection UniqueElementData::Attributes() {
  return MutableAttributeCollection(attribute_vector_);
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_ELEMENT_DATA_H_
