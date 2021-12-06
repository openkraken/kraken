/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_NODE_LIST_H
#define KRAKENBRIDGE_NODE_LIST_H

#include "node.h"

namespace kraken::binding::qjs {

class NodeList : public HostObject {
 public:
  explicit NodeList(JSContext* context, NodeInstance* rootNode);

 private:
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_NODE_LIST_H
