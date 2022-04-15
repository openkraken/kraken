/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_template_element.h"
#include "html_names.h"

namespace kraken {

HTMLTemplateElement::HTMLTemplateElement(Document& document) : HTMLElement(html_names::ktemplate, &document) {}
}  // namespace kraken
