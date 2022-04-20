/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_html_element.h"
#include "html_names.h"

namespace kraken {

HTMLHtmlElement::HTMLHtmlElement(Document& document) : HTMLElement(html_names::khtml, &document) {}

}  // namespace kraken
