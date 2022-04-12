/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "container_node.h"
#include "tree_scope.h"

namespace kraken {

class Text;

// A document (https://dom.spec.whatwg.org/#concept-document) is the root node
// of a tree of DOM nodes, generally resulting from the parsing of a markup
// (typically, HTML) resource.
class Document : public Node, TreeScope {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = Document*;

  Text* createTextNode(const AtomicString& value);

  void IncrementNodeCount() { node_count_++; }
  void DecrementNodeCount() {
    assert(node_count_ > 0);
    node_count_--;
  }
  int NodeCount() const { return node_count_; }

 private:
  int node_count_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_DOCUMENT_H
