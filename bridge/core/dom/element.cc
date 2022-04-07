/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken {

Element::Element(ExecutingContext* context,
                 const AtomicString& tag_name,
                 Document* document,
                 Node::ConstructionType construction_type)
    : ContainerNode(context, construction_type) {}

bool Element::hasAttribute(const AtomicString&) const {
  return false;
}

const AtomicString& Element::getAttribute(const AtomicString&) const {
  return <#initializer #>;
}

}  // namespace kraken
