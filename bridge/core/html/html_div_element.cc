/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "html_div_element.h"
#include "html_names.h"

namespace kraken {

HTMLDivElement::HTMLDivElement(Document& document) : HTMLElement(html_names::kdiv, &document) {}

}  // namespace kraken
