/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_input_element.h"
#include "html_names.h"

namespace kraken {

HTMLInputElement::HTMLInputElement(Document& document) : HTMLElement(html_names::kinput, &document) {}

}  // namespace kraken
