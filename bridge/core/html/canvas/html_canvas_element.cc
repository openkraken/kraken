/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_canvas_element.h"
#include "html_names.h"

namespace kraken {

HTMLCanvasElement::HTMLCanvasElement(Document& document) : HTMLElement(html_names::kcanvas, &document) {}
}  // namespace kraken
