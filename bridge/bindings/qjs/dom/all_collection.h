/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ALL_COLLECTION_H
#define KRAKENBRIDGE_ALL_COLLECTION_H

#include "bindings/qjs/host_object.h"
#include "node.h"

namespace kraken::binding::qjs {

class AllCollection : public HostObject {
 public:
  AllCollection(JSContext* context) : HostObject(context, "AllCollection"){};

  static JSValue item(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue add(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue remove(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  DEFINE_READONLY_PROPERTY(length);

  void internalAdd(NodeInstance* node, NodeInstance* before);

 private:
  std::vector<NodeInstance*> m_nodes;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_ALL_COLLECTION_H
