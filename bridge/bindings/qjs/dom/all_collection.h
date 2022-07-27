/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_ALL_COLLECTION_H
#define BRIDGE_ALL_COLLECTION_H

#include "bindings/qjs/host_object.h"
#include "node.h"

namespace webf::binding::qjs {

class AllCollection : public HostObject {
 public:
  AllCollection(ExecutionContext* context) : HostObject(context, "AllCollection"){};

  static JSValue item(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue add(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue remove(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  DEFINE_READONLY_PROPERTY(length);

  void internalAdd(NodeInstance* node, NodeInstance* before);

 private:
  std::vector<NodeInstance*> m_nodes;
};

}  // namespace webf::binding::qjs

#endif  // BRIDGE_ALL_COLLECTION_H
