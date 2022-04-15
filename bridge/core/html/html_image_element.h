/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_

#include "html_element.h"

namespace kraken {

class HTMLImageElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit HTMLImageElement(Document& document);

 private:
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_
