/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_HTML_BODY_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_HTML_BODY_ELEMENT_H_

#include "html_element.h"

namespace kraken {

class HTMLBodyElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit HTMLBodyElement(Document&);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_HTML_HTML_BODY_ELEMENT_H_
