/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "bindings/qjs/cppgc/garbage_collected.h"
#include "container_node.h"
#include "core/css/legacy/css_style_declaration.h"
#include "legacy/bounding_client_rect.h"
#include "legacy/element_attributes.h"
#include "qjs_scroll_to_options.h"

namespace kraken {

class Element : public ContainerNode {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = Element*;
  Element(const AtomicString& tag_name, Document* document, ConstructionType = kCreateElement);

  ElementAttributes* attributes() { return &EnsureElementAttributes(); }
  ElementAttributes& EnsureElementAttributes();

  bool hasAttribute(const AtomicString&, ExceptionState& exception_state);
  AtomicString getAttribute(const AtomicString&, ExceptionState& exception_state);

  // Passing null as the second parameter removes the attribute when
  // calling either of these set methods.
  void setAttribute(const AtomicString&, const AtomicString& value);
  void setAttribute(const AtomicString&, const AtomicString& value, ExceptionState&);
  void removeAttribute(const AtomicString&, ExceptionState& exception_state);
  BoundingClientRect* getBoundingClientRect(ExceptionState& exception_state);
  void click(ExceptionState& exception_state);
  void scroll(ExceptionState& exception_state);
  void scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scroll(double x, double y, ExceptionState& exception_state);
  void scrollTo(ExceptionState& exception_state);
  void scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollTo(double x, double y, ExceptionState& exception_state);
  void scrollBy(ExceptionState& exception_state);
  void scrollBy(double x, double y, ExceptionState& exception_state);
  void scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);

  ScriptPromise toBlob(double device_pixel_ratio, ExceptionState& exception_state);
  ScriptPromise toBlob(ExceptionState& exception_state);

  double clientHeight() const;
  double clientWidth() const;
  double clientLeft() const;
  double clientTop() const;

  double scrollTop() const;
  void setScrollTop(double v, ExceptionState& exception_state);
  double scrollLeft() const;
  void setScrollLeft(double v, ExceptionState& exception_state);

  std::string outerHTML() const;
  void setOuterHTML(const AtomicString& value, ExceptionState& exception_state);
  std::string innerHTML() const;
  void setInnerHTML(const AtomicString& value, ExceptionState& exception_state);

  bool HasTagName(const AtomicString&) const;
  std::string nodeValue() const override;
  AtomicString tagName() const { return tag_name_; }
  std::string nodeName() const override;

  CSSStyleDeclaration* style();
  CSSStyleDeclaration& EnsureCSSStyleDeclaration();

  Element& CloneWithChildren(CloneChildrenFlag flag, Document* = nullptr) const;
  Element& CloneWithoutChildren(Document* = nullptr) const;

  NodeType nodeType() const override;
  bool ChildTypeAllowed(NodeType) const override;

  // Clones attributes only.
  void CloneAttributesFrom(const Element&);
  bool HasEquivalentAttributes(const Element& other) const;

  // Step 5 of https://dom.spec.whatwg.org/#concept-node-clone
  virtual void CloneNonAttributePropertiesFrom(const Element&, CloneChildrenFlag) {}

  void Trace(GCVisitor* visitor) const override;

 protected:
 private:
  // Clone is private so that non-virtual CloneElementWithChildren and
  // CloneElementWithoutChildren are used inst
  Node* Clone(Document&, CloneChildrenFlag) const override;
  virtual Element& CloneWithoutAttributesAndChildren(Document& factory) const;

  void _notifyNodeRemoved(Node* node);
  void _notifyChildRemoved();
  void _notifyNodeInsert(Node* insertNode);
  void _notifyChildInsert();
  void _didModifyAttribute(const AtomicString& name, const AtomicString& oldId, const AtomicString& newId);
  void _beforeUpdateId(JSValue oldIdValue, JSValue newIdValue);

  Member<ElementAttributes> attributes_;
  Member<CSSStyleDeclaration> cssom_wrapper_;
  AtomicString tag_name_ = AtomicString::Empty(ctx());
};

template <typename T>
bool IsElementOfType(const Node&);
template <>
inline bool IsElementOfType<const Element>(const Node& node) {
  return node.IsElementNode();
}
template <typename T>
inline bool IsElementOfType(const Element& element) {
  return IsElementOfType<T>(static_cast<const Node&>(element));
}
template <>
inline bool IsElementOfType<const Element>(const Element&) {
  return true;
}

template <>
struct DowncastTraits<Element> {
  static bool AllowFrom(const Node& node) { return node.IsElementNode(); }
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_ELEMENT_H
