/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HTML_TEMPLATE_ELEMENT_H
#define KRAKENBRIDGE_HTML_TEMPLATE_ELEMENT_H

#include "html_element.h"

namespace kraken {

class DocumentFragment;

class HTMLTemplateElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit HTMLTemplateElement(Document& document);

  DocumentFragment* content() const;

 private:
  DocumentFragment* ContentInternal() const;
  mutable Member<DocumentFragment> content_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_TEMPLATE_ELEMENTT_H
