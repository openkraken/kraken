/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_HTML_DIV_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_HTML_DIV_ELEMENT_H_

#include "html_element.h"

namespace kraken {

class HTMLDivElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();
 public:

  explicit HTMLDivElement(Document&);

 private:

};

}

#endif  // KRAKENBRIDGE_CORE_HTML_HTML_DIV_ELEMENT_H_
