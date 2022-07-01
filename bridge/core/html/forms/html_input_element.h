/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_FORMS_HTML_INPUT_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_FORMS_HTML_INPUT_ELEMENT_H_

#include "core/html/html_element.h"

namespace kraken {

class HTMLInputElement : public HTMLElement {
 public:
  explicit HTMLInputElement(Document&);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_HTML_FORMS_HTML_INPUT_ELEMENT_H_
