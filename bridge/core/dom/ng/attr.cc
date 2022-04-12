/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "attr.h"
#include "element.h"

namespace kraken {

Attr::Attr(Element& element, const AtomicString& name)
    : Node(&element.GetDocument(), kCreateOther), element_(&element), name_(name) {}

}  // namespace kraken
