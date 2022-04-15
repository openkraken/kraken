/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_anchor_element.h"
#include "html_names.h"

namespace kraken {

HTMLAnchorElement::HTMLAnchorElement(Document& document): HTMLElement(html_names::ka, &document) {}

}
