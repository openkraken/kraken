/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_HTML_UNKNOWN_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_HTML_UNKNOWN_ELEMENT_H_

#include "core/html/html_element.h"

namespace kraken {

class HTMLUnknownElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();
 public:
  explicit HTMLUnknownElement(const AtomicString&, Document& document);
 private:

};

}

#endif  // KRAKENBRIDGE_CORE_HTML_HTML_UNKNOWN_ELEMENT_H_
