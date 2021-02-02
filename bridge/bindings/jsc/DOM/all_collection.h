/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ALL_COLLECTION_H
#define KRAKENBRIDGE_ALL_COLLECTION_H

#include "bindings/jsc/DOM/node.h"
#include "bindings/jsc/host_object.h"
#include "bindings/jsc/js_context_internal.h"
#include <vector>

namespace kraken::binding::jsc {

class JSAllCollection : public HostObject {
public:
  JSAllCollection() = delete;
  explicit JSAllCollection(JSContext *context) : HostObject(context, "HTMLAllCollection") {};
  DEFINE_OBJECT_PROPERTY(AllCollection, 4, item, add, remove, length)

  static JSValueRef item(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef add(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef remove(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

  void internalAdd(JSNode::NodeInstance *node, JSNode::NodeInstance *before);

private:
  std::vector<JSNode::NodeInstance *> m_nodes;
  JSFunctionHolder m_item{context, this, "item", item};
  JSFunctionHolder m_add{context, this, "add", add};
  JSFunctionHolder m_remove{context, this, "remove", remove};
};

}

#endif // KRAKENBRIDGE_ALL_COLLECTION_H
