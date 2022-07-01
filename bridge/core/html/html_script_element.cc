/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_script_element.h"
#include "html_names.h"

namespace kraken {

HTMLScriptElement::HTMLScriptElement(Document& document) : HTMLElement(html_names::kscript, &document) {}

}  // namespace kraken
