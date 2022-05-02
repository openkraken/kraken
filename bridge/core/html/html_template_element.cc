/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_template_element.h"
#include "html_names.h"
#include "core/dom/document_fragment.h"

namespace kraken {

HTMLTemplateElement::HTMLTemplateElement(Document& document) : HTMLElement(html_names::ktemplate, &document) {}

DocumentFragment* HTMLTemplateElement::content() const {
  return ContentInternal();
}

DocumentFragment* HTMLTemplateElement::ContentInternal() const {
  if (!content_ && GetExecutingContext())
    content_ = DocumentFragment::Create(GetDocument());

  return content_.Get();
}

}  // namespace kraken
