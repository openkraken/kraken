/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HTML_ANCHOR_ELEMENT_H
#define KRAKENBRIDGE_HTML_ANCHOR_ELEMENT_H

#include "html_element.h"

namespace kraken {

class HTMLAnchorElement : public HTMLElement {
 public:
  explicit HTMLAnchorElement(Document&);
};

}

#endif  // KRAKENBRIDGE_HTML_ANCHOR_ELEMENT_H
