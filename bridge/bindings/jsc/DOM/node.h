/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_NODE_H
#define KRAKENBRIDGE_NODE_H

#include "event_target.h"
#include "include/kraken_bridge.h"
#include <array>
#include <vector>

namespace kraken::binding::jsc {

enum NodeType {
  ELEMENT_NODE = 1,
  TEXT_NODE = 3,
  COMMENT_NODE = 8,
  DOCUMENT_NODE = 9,
  DOCUMENT_TYPE_NODE = 10,
  DOCUMENT_FRAGMENT_NODE = 11
};

void bindNode(std::unique_ptr<JSContext> &context);

struct NativeNode;
class JSDocument;
class DocumentInstance;

class JSNode : public JSEventTarget {
public:
  static std::unordered_map<JSContext *, JSNode *> instanceMap;
  static JSNode *instance(JSContext *context);
  DEFINE_OBJECT_PROPERTY(Node, 14, isConnected, firstChild, lastChild, parentNode, childNodes, previousSibling,
                         nextSibling, appendChild, remove, removeChild, insertBefore, replaceChild, nodeType,
                         textContent)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  static JSValueRef appendChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception);
  /**
   * The ChildNode.remove() method removes the object
   * from the tree it belongs to.
   * reference: https://dom.spec.whatwg.org/#dom-childnode-remove
   */
  static JSValueRef remove(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef removeChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef insertBefore(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef replaceChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);

  JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception) override;

  class NodeInstance : public EventTargetInstance {
  public:
    NodeInstance() = delete;
    NodeInstance(JSNode *node, NodeType nodeType);
    NodeInstance(JSNode *node, NodeType nodeType, int64_t targetId);
    ~NodeInstance() override;

    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    bool isConnected();
    JSNode::NodeInstance *firstChild();
    JSNode::NodeInstance *lastChild();
    JSNode::NodeInstance *previousSibling();
    JSNode::NodeInstance *nextSibling();
    void internalAppendChild(JSNode::NodeInstance *node);
    void internalRemove(JSValueRef *exception);
    JSNode::NodeInstance *internalRemoveChild(JSNode::NodeInstance *node, JSValueRef *exception);
    void internalInsertBefore(JSNode::NodeInstance *node, JSNode::NodeInstance *referenceNode, JSValueRef *exception);
    virtual std::string internalGetTextContent();
    virtual void internalSetTextContent(JSStringRef content, JSValueRef *exception);
    JSNode::NodeInstance *internalReplaceChild(JSNode::NodeInstance *newChild, JSNode::NodeInstance *oldChild);

    NodeType nodeType;
    JSNode::NodeInstance *parentNode{nullptr};
    std::vector<JSNode::NodeInstance *> childNodes;

    NativeNode *nativeNode{nullptr};

    void refer();
    void unrefer();

    int32_t _referenceCount{0};

    DocumentInstance *document{nullptr};
    virtual void _notifyNodeRemoved(JSNode::NodeInstance *node);
    virtual void _notifyNodeInsert(JSNode::NodeInstance *node);

  private:
    void ensureDetached(JSNode::NodeInstance *node);
  };

protected:
  JSNode() = delete;
  explicit JSNode(JSContext *context);
  explicit JSNode(JSContext *context, const char *name);
  ~JSNode();

private:
  JSFunctionHolder m_removeChild{context, this, "removeChild", removeChild};
  JSFunctionHolder m_appendChild{context, this, "appendChild", appendChild};
  JSFunctionHolder m_remove{context, this, "remove", remove};
  JSFunctionHolder m_insertBefore{context, this, "insertBefore", insertBefore};
  JSFunctionHolder m_replaceChild{context, this, "replaceChild", replaceChild};
};

struct NativeNode {
  NativeNode() = delete;
  NativeNode(NativeEventTarget *nativeEventTarget) : nativeEventTarget(nativeEventTarget){};
  NativeEventTarget *nativeEventTarget;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_NODE_H
