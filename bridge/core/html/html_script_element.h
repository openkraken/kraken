/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_HTML_SCRIPT_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_HTML_SCRIPT_ELEMENT_H_

#include "html_element.h"

namespace kraken {

class HTMLScriptElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();
 public:

  explicit HTMLScriptElement(Document& document);

 private:

};

}

#endif  // KRAKENBRIDGE_CORE_HTML_HTML_SCRIPT_ELEMENT_H_
