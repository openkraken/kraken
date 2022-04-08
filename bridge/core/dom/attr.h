/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_ATTR_H_
#define KRAKENBRIDGE_CORE_DOM_ATTR_H_

#include "bindings/qjs/atomic_string.h"
#include "node.h"

namespace kraken {

class Element;
class Document;

class Attr : public Node {
  DEFINE_WRAPPERTYPEINFO();

 public:
  Attr(Element& element, const AtomicString& name);
  Attr(Document& document, const AtomicString& name, const AtomicString& value);

  ~Attr() override;

  std::string name() const { return name_.ToStdString(); }
  bool specified() const { return true; }
  Element* ownerElement() const { return element_; }

  const AtomicString& value() const;
  void setValue(const AtomicString&, ExceptionState&);

  const QualifiedName GetQualifiedName() const;

  void AttachToElement(Element*, const AtomicString&);
  void DetachFromElementWithValue(const AtomicString&);

  const AtomicString& localName() const { return name_.LocalName(); }
  const AtomicString& namespaceURI() const { return name_.NamespaceURI(); }
  const AtomicString& prefix() const { return name_.Prefix(); }

  void Trace(Visitor*) const override;

  const AtomicString& localName() const { return name_; }

 private:
  bool IsElementNode() const = delete;  // This will catch anyone doing an unnecessary check.

  std::string nodeName() const override { return name(); }
  NodeType nodeType() const override { return kAttributeNode; }

  std::string nodeValue() const override { return value().ToStdString(); }
  void setNodeValue(const std::string& node_value, ExceptionState& exception_state) override;
  void setTextContentForBinding(const V8UnionStringOrTrustedScript* value, ExceptionState& exception_state) override;
  Node* Clone(Document&, CloneChildrenFlag) const override;

  bool IsAttributeNode() const override { return true; }

  Element* element_;
  AtomicString name_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_ATTR_H_
