/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_EMPTY_NODE_LIST_H_
#define KRAKENBRIDGE_CORE_DOM_EMPTY_NODE_LIST_H_

#include "node_list.h"

namespace kraken {

class ExceptionState;

class EmptyNodeList : public NodeList {
 public:
  explicit EmptyNodeList(Node* root_node);

  Node& OwnerNode() const { return *owner_; }
  void Trace(GCVisitor* visitor) const override;

 private:
  unsigned length() const override { return 0; }
  Node* item(unsigned, ExceptionState& exception_state) const override { return nullptr; }

  bool IsEmptyNodeList() const override { return true; }
  Node* VirtualOwnerNode() const override;

  Node* owner_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_EMPTY_NODE_LIST_H_
