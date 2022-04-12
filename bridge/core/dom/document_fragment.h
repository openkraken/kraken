/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_FRAGMENT_H
#define KRAKENBRIDGE_DOCUMENT_FRAGMENT_H

#include "container_node.h"

namespace kraken {

class DocumentFragment : public ContainerNode {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static DocumentFragment* Create(Document* document, ExceptionState& exception_state);

  DocumentFragment(Document* document, ConstructionType type);

  virtual bool IsTemplateContent() const { return false; }

  // This will catch anyone doing an unnecessary check.
  bool IsDocumentFragment() const = delete;

 protected:
  std::string nodeName() const final;

 private:
  NodeType nodeType() const final;
  Node* Clone(Document&, CloneChildrenFlag) const override;
  bool ChildTypeAllowed(NodeType) const override;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_DOCUMENT_FRAGMENT_H
