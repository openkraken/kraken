/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "tree_scope.h"
#include "document.h"

namespace kraken {

TreeScope::TreeScope(Document& document) : root_node_(&document), document_(&document) {
  root_node_->SetTreeScope(this);
}

}  // namespace kraken
