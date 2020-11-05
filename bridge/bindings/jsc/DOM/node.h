/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_NODE_H
#define KRAKENBRIDGE_NODE_H

#include "eventTarget.h"
#include "include/kraken_bridge.h"
#include <vector>
#include <array>

namespace kraken::binding::jsc {

enum NodeType {
  ELEMENT_NODE = 1,
  TEXT_NODE = 3,
  COMMENT_NODE = 8,
  DOCUMENT_NODE = 9,
  DOCUMENT_TYPE_NODE = 10,
  DOCUMENT_FRAGMENT_NODE = 11
};

class JSNode : public JSEventTarget {
public:
  JSNode() = delete;
  explicit JSNode(JSContext *context);
  explicit JSNode(JSContext *context, const char *name);

  class NodeInstance : public EventTargetInstance {
  public:
    NodeInstance() = delete;
    NodeInstance(JSNode *node, NodeType nodeType);
    ~NodeInstance();

    static JSValueRef appendChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);
    /**
     * The ChildNode.remove() method removes the object
     * from the tree it belongs to.
     * reference: https://dom.spec.whatwg.org/#dom-childnode-remove
     */
    static JSValueRef remove(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);

    static JSValueRef insertBefore(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

    static JSValueRef replaceChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

    JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
    void setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) override;

    bool isConnected();
    JSNode::NodeInstance *firstChild();
    JSNode::NodeInstance *lastChild();
    JSNode::NodeInstance *previousSibling();
    JSNode::NodeInstance *nextSibling();
    void internalAppendChild(JSNode::NodeInstance *node);
    void internalRemove(JSValueRef *exception);
    JSNode::NodeInstance *internalRemoveChild(JSNode::NodeInstance *node, JSValueRef *exception);
    void internalInsertBefore(JSNode::NodeInstance *node, JSNode::NodeInstance *referenceNode);
    JSNode::NodeInstance *internalReplaceChild(JSNode::NodeInstance *newChild, JSNode::NodeInstance *oldChild);

  private:
    void ensureDetached(JSNode::NodeInstance *node);
    NodeType nodeType;
    std::vector<JSNode::NodeInstance *> childNodes;
    JSNode::NodeInstance *parentNode{nullptr};

    std::array<JSStringRef, 9> propertyNames{
        JSStringCreateWithUTF8CString("isConnected"),
        JSStringCreateWithUTF8CString("firstChild"),
        JSStringCreateWithUTF8CString("lastChild"),
        JSStringCreateWithUTF8CString("previousSibling"),
        JSStringCreateWithUTF8CString("nextSibling"),
        JSStringCreateWithUTF8CString("appendChild"),
        JSStringCreateWithUTF8CString("remove"),
        JSStringCreateWithUTF8CString("insertBefore"),
        JSStringCreateWithUTF8CString("replaceChild"),
    };
  };
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_NODE_H
