/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_TREE_SCOPE_H_
#define KRAKENBRIDGE_CORE_DOM_TREE_SCOPE_H_

#include <assert.h>

namespace kraken {

class ContainerNode;
class Document;

class TreeScope {
  friend class Node;

 public:
  Document& GetDocument() const {
    assert(document_);
    return *document_;
  }

 protected:
  explicit TreeScope(ContainerNode&, Document&);

 private:
  ContainerNode* root_node_;
  Document* document_;
  TreeScope* parent_tree_scope_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_TREE_SCOPE_H_
