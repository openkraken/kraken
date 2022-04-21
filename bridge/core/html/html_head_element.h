/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_HTML_HEAD_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_HTML_HEAD_ELEMENT_H_

#include "html_element.h"

namespace kraken {

class HTMLHeadElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType  = HTMLHeadElement*;
  explicit HTMLHeadElement(Document&);

 private:
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_HTML_HTML_HEAD_ELEMENT_H_
