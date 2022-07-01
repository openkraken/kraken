/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_CANVAS_HTML_CANVAS_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_CANVAS_HTML_CANVAS_ELEMENT_H_

#include "core/html/html_element.h"

namespace kraken {

class HTMLCanvasElement : public HTMLElement {
 public:
  explicit HTMLCanvasElement(Document&);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_HTML_CANVAS_HTML_CANVAS_ELEMENT_H_
