/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_NODE_H
#define KRAKENBRIDGE_NODE_H

#include <utility>

#include "event_target.h"

namespace kraken::binding::qjs {

void bindNode(std::unique_ptr<JSContext> &context);

enum NodeType {
  ELEMENT_NODE = 1,
  TEXT_NODE = 3,
  COMMENT_NODE = 8,
  DOCUMENT_NODE = 9,
  DOCUMENT_TYPE_NODE = 10,
  DOCUMENT_FRAGMENT_NODE = 11
};

class NodeInstance;
class ElementInstance;
class DocumentInstance;
class TextNodeInstance;

class Node : public EventTarget {
public:
  Node() = delete;
  Node(JSContext *context, const std::string &className) : EventTarget(context, className.c_str()) {
    JS_SetPrototype(m_ctx, m_prototypeObject, EventTarget::instance(m_context)->prototype());
  }
  Node(JSContext *context) : EventTarget(context, "Node") {
    JS_SetPrototype(m_ctx, m_prototypeObject, EventTarget::instance(m_context)->prototype());
  }

  OBJECT_INSTANCE(Node);

  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;

  static JSClassID classId();

  static JSClassID classId(JSValue &value);

  static JSValue cloneNode(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue appendChild(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue remove(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue removeChild(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue insertBefore(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue replaceChild(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

private:
  DEFINE_HOST_CLASS_PROPERTY(10, isConnected, ownerDocument, firstChild, lastChild, parentNode, childNodes,
                             previousSibling, nextSibling, nodeType, textContent);
  ObjectFunction m_cloneNode{m_context, m_prototypeObject, "cloneNode", cloneNode, 1};
  ObjectFunction m_appendChild{m_context, m_prototypeObject, "appendChild", appendChild, 1};
  ObjectFunction m_remove{m_context, m_prototypeObject, "remove", remove, 0};
  ObjectFunction m_removeChild{m_context, m_prototypeObject, "removeChild", removeChild, 1};
  ObjectFunction m_insertBefore{m_context, m_prototypeObject, "insertBefore", insertBefore, 2};
  ObjectFunction m_replaceChild{m_context, m_prototypeObject, "replaceChild", replaceChild, 2};

  static void traverseCloneNode(QjsContext *ctx, NodeInstance *element, NodeInstance *parentElement);
  static JSValue copyNodeValue(QjsContext *ctx, NodeInstance *element);
  friend ElementInstance;
  friend TextNodeInstance;
};

struct NodeLink {
  NodeInstance *nodeInstance;
  list_head link;
};

class NodeInstance : public EventTargetInstance {
public:
  NodeInstance() = delete;
  explicit NodeInstance(Node *node, NodeType nodeType, DocumentInstance *document, JSClassID classId, std::string name) : EventTargetInstance(node, classId, std::move(name)),
                                                                                     m_document(document), nodeType(nodeType) {
  }
  explicit NodeInstance(Node *node, NodeType nodeType, DocumentInstance *document, JSClassID classId, JSClassExoticMethods &exoticMethods, std::string name) :
    EventTargetInstance(node, classId, exoticMethods, name), m_document(document), nodeType(nodeType) {
  }
  ~NodeInstance();
  bool isConnected();
  DocumentInstance *ownerDocument();
  NodeInstance *firstChild();
  NodeInstance *lastChild();
  NodeInstance *previousSibling();
  NodeInstance *nextSibling();
  void internalAppendChild(NodeInstance *node);
  void internalRemove();
  NodeInstance *internalRemoveChild(NodeInstance *node);
  JSValue internalInsertBefore(NodeInstance *node, NodeInstance *referenceNode);
  virtual JSValue internalGetTextContent();
  virtual void internalSetTextContent(JSValue content);
  JSValue internalReplaceChild(NodeInstance *newChild, NodeInstance *oldChild);

  void setParentNode(NodeInstance *parent);
  void removeParentNode();
  NodeType nodeType;
  NodeInstance *parentNode{nullptr};
  std::vector<NodeInstance *> childNodes;

  NodeLink nodeLink{this};
  NodeLink documentLink{this};

  void refer();
  void unrefer();
  inline DocumentInstance *document() {
    return m_document;
  }

  virtual void _notifyNodeRemoved(NodeInstance *node);
  virtual void _notifyNodeInsert(NodeInstance *node);

private:
  DocumentInstance *m_document{nullptr};
  void ensureDetached(NodeInstance *node);
  friend DocumentInstance;
  friend Node;
  friend ElementInstance;
  int32_t _referenceCount{0};
};

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_NODE_H
