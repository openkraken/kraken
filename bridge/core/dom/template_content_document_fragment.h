/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_TEMPLATE_CONTENT_DOCUMENT_FRAGMENT_H_
#define KRAKENBRIDGE_CORE_DOM_TEMPLATE_CONTENT_DOCUMENT_FRAGMENT_H_

#include "bindings/qjs/gc_visitor.h"
#include "document_fragment.h"
#include "element.h"

namespace kraken {

class TemplateContentDocumentFragment final : public DocumentFragment {
 public:
  TemplateContentDocumentFragment(Document& document, Element* host)
      : DocumentFragment(&document, kCreateDocumentFragment), host_(host) {}

  Element* Host() const { return host_; }

  void Trace(GCVisitor* visitor) const override {
    visitor->Trace(host_);
    DocumentFragment::Trace(visitor);
  }

 private:
  bool IsTemplateContent() const override { return true; }
  Element* host_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_TEMPLATE_CONTENT_DOCUMENT_FRAGMENT_H_
