/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_TREE_SCOPE_H_
#define KRAKENBRIDGE_CORE_DOM_TREE_SCOPE_H_

#include <cassert>

namespace kraken {

class ContainerNode;
class Document;

// The root node of a document tree (in which case this is a Document) or of a
// shadow tree (in which case this is a ShadowRoot). Various things, like
// element IDs, are scoped to the TreeScope in which they are rooted, if any.
//
// A class which inherits both Node and TreeScope must call clearRareData() in
// its destructor so that the Node destructor no longer does problematic
// NodeList cache manipulation in the destructor.
class TreeScope {
  friend class Node;

 public:
  Document& GetDocument() const {
    assert(document_);
    return *document_;
  }

 protected:
  explicit TreeScope(Document&);

 private:
  ContainerNode* root_node_;
  Document* document_;
  TreeScope* parent_tree_scope_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_TREE_SCOPE_H_
