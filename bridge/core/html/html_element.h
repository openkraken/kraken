/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_HTML_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_HTML_ELEMENT_H_

#include "core/dom/element.h"

namespace kraken {

class HTMLElement : public Element {
  DEFINE_WRAPPERTYPEINFO();

 public:
  HTMLElement(const AtomicString& tag_name, Document* document, ConstructionType);

 private:
};

inline HTMLElement::HTMLElement(const AtomicString& tag_name,
                                Document* document,
                                ConstructionType type = kCreateHTMLElement)
    : Element(tag_name, document, type) {}

template <typename T>
bool IsElementOfType(const HTMLElement&);
template <>
inline bool IsElementOfType<const HTMLElement>(const HTMLElement&) {
  return true;
}
template <>
inline bool IsElementOfType<const HTMLElement>(const Node& node) {
  return IsA<HTMLElement>(node);
}
template <>
struct DowncastTraits<HTMLElement> {
  static bool AllowFrom(const Node& node) { return node.IsHTMLElement(); }
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_HTML_HTML_ELEMENT_H_
