/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HTML_TEMPLATE_ELEMENT_H
#define KRAKENBRIDGE_HTML_TEMPLATE_ELEMENT_H

#include "core/dom/element.h"

namespace kraken {

class DocumentFragment;

class HTMLTemplateElement : public Element {
  DEFINE_WRAPPERTYPEINFO();

 public:
  DocumentFragment* content() const;

 private:
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_TEMPLATE_ELEMENTT_H
