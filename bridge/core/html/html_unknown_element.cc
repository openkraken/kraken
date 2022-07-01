/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_unknown_element.h"

namespace kraken {

HTMLUnknownElement::HTMLUnknownElement(const AtomicString& tag_name, Document& document)
    : HTMLElement(tag_name, &document) {}

}  // namespace kraken
