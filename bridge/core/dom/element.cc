/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"

namespace kraken {

Element::Element(Document* document,
                 const AtomicString& tag_name,
                 Node::ConstructionType construction_type)
    : ContainerNode(document, construction_type) {}

bool Element::hasAttribute(const AtomicString& name) const {
  if (!GetElementData())
    return false;
  AtomicString result = name.LowercaseIfNecessary();
//  SynchronizeAttributeHinted(local_name, hint);
//  if (hint.IsNull()) {
//    return false;
//  }
//  for (const Attribute& attribute : GetElementData()->Attributes()) {
//    if (hint == attribute.LocalName())
//      return true;
//  }
  return false;

  return false;
}

const AtomicString& Element::getAttribute(const AtomicString&) const {
}

void Element::setAttribute(const AtomicString& name, const AtomicString& value) {
  ExceptionState exception_state;
  return setAttribute(name, value, exception_state);
}

void Element::setAttribute(const AtomicString&, const AtomicString& value, ExceptionState&) {

}

}  // namespace kraken
