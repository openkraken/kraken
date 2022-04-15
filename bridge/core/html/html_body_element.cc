/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_body_element.h"
#include "html_names.h"

namespace kraken {

HTMLBodyElement::HTMLBodyElement(Document& document): HTMLElement(html_names::kbody, &document){}

}
