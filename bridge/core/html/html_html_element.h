/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_HTML_HTML_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_HTML_HTML_ELEMENT_H_

#include "html_element.h"

namespace kraken {

class HTMLHtmlElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType  = HTMLHtmlElement*;
  explicit HTMLHtmlElement(Document&);

 private:
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_HTML_HTML_HTML_ELEMENT_H_
