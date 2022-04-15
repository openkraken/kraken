/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_textarea_element.h"
#include "html_names.h"

namespace kraken {

HTMLTextareaElement::HTMLTextareaElement(Document& document) : HTMLElement(html_names::ktextarea, &document) {}


}
