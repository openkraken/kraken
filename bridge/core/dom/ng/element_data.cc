/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "element_data.h"

namespace kraken {

ElementData::~ElementData() {
  if (auto* unique_element_data = DynamicTo<UniqueElementData>(this))
    unique_element_data->~UniqueElementData();
  else
    To<ShareableElementData>(this)->~ShareableElementData();
}

std::shared_ptr<UniqueElementData> ElementData::MakeUniqueCopy() const {
  if (auto* unique_element_data = DynamicTo<UniqueElementData>(this))
    return std::make_shared<UniqueElementData>(*unique_element_data);
  return std::make_shared<UniqueElementData>(To<ShareableElementData>(*this));
}

bool ElementData::IsEquivalent(const ElementData* other) const {
  AttributeCollection attributes = Attributes();
  if (!other)
    return attributes.IsEmpty();

  AttributeCollection other_attributes = other->Attributes();
  if (attributes.size() != other_attributes.size())
    return false;

  for (const Attribute& attribute : attributes) {
    const Attribute* other_attr = other_attributes.Find(attribute.GetName());
    if (!other_attr || attribute.Value() != other_attr->Value())
      return false;
  }
  return true;
}

}  // namespace kraken
