/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_NODE_LIST_H_
#define KRAKENBRIDGE_CORE_DOM_NODE_LIST_H_

#include "bindings/qjs/script_wrappable.h"

namespace kraken {

class Node;

class NodeList : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  NodeList(JSContext* ctx) : ScriptWrappable(ctx){};
  ~NodeList() override = default;

  // DOM methods & attributes for NodeList
  virtual unsigned length() const = 0;
  virtual Node* item(unsigned index) const = 0;

  // Other methods (not part of DOM)
  virtual bool IsEmptyNodeList() const { return false; }
  virtual bool IsChildNodeList() const { return false; }

  const char* GetHumanReadableName() const override { return "NodeList"; };

  virtual Node* VirtualOwnerNode() const { return nullptr; }

 protected:
  NodeList() = default;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_NODE_LIST_H_
