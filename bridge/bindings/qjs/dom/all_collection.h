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
  AllCollection(JSContext *context): HostObject(context, "AllCollection") {};

  static JSValue item(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue add(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue remove(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

  DEFINE_HOST_OBJECT_PROPERTY(1, length);

  void internalAdd(NodeInstance *node, NodeInstance *before);
private:
  std::vector<NodeInstance *> m_nodes;
};

}

//class JSAllCollection : public HostObject {
//public:
//  JSAllCollection() = delete;
//  explicit JSAllCollection(JSContext *context) : HostObject(context, "HTMLAllCollection") {};
//  DEFINE_OBJECT_PROPERTY(AllCollection, 4, length, item, add, remove)
//
//  static JSValueRef item(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                         const JSValueRef arguments[], JSValueRef *exception);
//
//  static JSValueRef add(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                        const JSValueRef arguments[], JSValueRef *exception);
//
//  static JSValueRef remove(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                           const JSValueRef arguments[], JSValueRef *exception);
//
//  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
//  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
//
//  void internalAdd(NodeInstance *node, NodeInstance *before);
//
//private:
//  std::vector<NodeInstance *> m_nodes;
//  JSFunctionHolder m_item{context, jsObject, this, "item", item};
//  JSFunctionHolder m_add{context, jsObject, this, "add", add};
//  JSFunctionHolder m_remove{context, jsObject, this, "remove", remove};
//};


#endif //KRAKENBRIDGE_ALL_COLLECTION_H
