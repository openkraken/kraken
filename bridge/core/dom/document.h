/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "container_node.h"
#include "tree_scope.h"
#include "core/dom/document_fragment.h"
#include "core/dom/text.h"
#include "core/dom/comment.h"

namespace kraken {

// A document (https://dom.spec.whatwg.org/#concept-document) is the root node
// of a tree of DOM nodes, generally resulting from the parsing of a markup
// (typically, HTML) resource.
class Document : public Node, TreeScope {
  DEFINE_WRAPPERTYPEINFO();
 public:
  using ImplType = Document*;

  explicit Document(ExecutingContext* context);

  static Document* Create(ExecutingContext* context, ExceptionState& exception_state);

  Element* createElement(const AtomicString& name, ExceptionState& exception_state);
  Text* createTextNode(const AtomicString& value, ExceptionState& exception_state);
  DocumentFragment* createDocumentFragment(ExceptionState& exception_state);
  Comment* createComment(ExceptionState& exception_state);

  std::string nodeName() const override;
  std::string nodeValue() const override;
  NodeType nodeType() const override;
  Node * Clone(Document &, CloneChildrenFlag) const override;

  void IncrementNodeCount() { node_count_++; }
  void DecrementNodeCount() {
    assert(node_count_ > 0);
    node_count_--;
  }
  int NodeCount() const { return node_count_; }

  // The following implements the rule from HTML 4 for what valid names are.
  static bool IsValidName(const AtomicString& name);

 private:
  int node_count_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_DOCUMENT_H
