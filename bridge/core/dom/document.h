/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "bindings/qjs/cppgc/local_handle.h"
#include "container_node.h"
#include "core/dom/comment.h"
#include "core/dom/document_fragment.h"
#include "core/dom/text.h"
#include "html_element_type_helper.h"
#include "scripted_animation_controller.h"
#include "tree_scope.h"

namespace kraken {

class HTMLBodyElement;
class HTMLHeadElement;
class HTMLHtmlElement;

// A document (https://dom.spec.whatwg.org/#concept-document) is the root node
// of a tree of DOM nodes, generally resulting from the parsing of a markup
// (typically, HTML) resource.
class Document : public ContainerNode, public TreeScope {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = Document*;

  explicit Document(ExecutingContext* context);

  static Document* Create(ExecutingContext* context, ExceptionState& exception_state);

  Element* createElement(const AtomicString& name, ExceptionState& exception_state);
  Text* createTextNode(const AtomicString& value, ExceptionState& exception_state);
  DocumentFragment* createDocumentFragment(ExceptionState& exception_state);
  Comment* createComment(ExceptionState& exception_state);

  [[nodiscard]] std::string nodeName() const override;
  [[nodiscard]] std::string nodeValue() const override;
  [[nodiscard]] NodeType nodeType() const override;
  [[nodiscard]] bool ChildTypeAllowed(NodeType) const override;

  // The following implements the rule from HTML 4 for what valid names are.
  static bool IsValidName(const AtomicString& name);

  Node* Clone(Document&, CloneChildrenFlag) const override;

  [[nodiscard]] HTMLHtmlElement* documentElement() const { return DynamicTo<HTMLHtmlElement>(document_element_.Get()); }
  void InitDocumentElement();

  // "body element" as defined by HTML5
  // (https://html.spec.whatwg.org/C/#the-body-element-2).
  // That is, the first body or frameset child of the document element.
  [[nodiscard]] HTMLBodyElement* body() const;
  void setBody(HTMLBodyElement* body, ExceptionState& exception_state);
  [[nodiscard]] HTMLHeadElement* head() const;
  void setHead(HTMLHeadElement* head, ExceptionState& exception_state);

  void IncrementNodeCount() { node_count_++; }
  void DecrementNodeCount() {
    assert(node_count_ > 0);
    node_count_--;
  }
  int NodeCount() const { return node_count_; }

  uint32_t RequestAnimationFrame(const std::shared_ptr<FrameCallback>& callback, ExceptionState& exception_state);
  void CancelAnimationFrame(uint32_t request_id, ExceptionState& exception_state);

  void Trace(GCVisitor* visitor) const override;

 private:
  int node_count_;
  Member<Element> document_element_;
  ScriptAnimationController script_animation_controller_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_DOCUMENT_H
