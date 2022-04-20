/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_head_element.h"
#include "html_names.h"

namespace kraken {

HTMLHeadElement::HTMLHeadElement(Document& document) : HTMLElement(html_names::khead, &document) {}

}  // namespace kraken
