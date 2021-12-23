/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_NODE_H
#define KRAKENBRIDGE_NODE_H

#include <set>
#include <utility>

#include "event_target.h"

namespace kraken::binding::qjs {

void bindNode(std::unique_ptr<ExecutionContext>& context);

enum NodeType { ELEMENT_NODE = 1, TEXT_NODE = 3, COMMENT_NODE = 8, DOCUMENT_NODE = 9, DOCUMENT_TYPE_NODE = 10, DOCUMENT_FRAGMENT_NODE = 11 };

class NodeInstance;
class ElementInstance;
class DocumentInstance;
class TextNodeInstance;

class Node : public EventTarget {
 public:
  Node() = delete;
  Node(ExecutionContext* context, const std::string& className) : EventTarget(context, className.c_str()) { JS_SetPrototype(m_ctx, m_prototypeObject, EventTarget::instance(m_context)->prototype()); }
  Node(ExecutionContext* context) : EventTarget(context, "Node") { JS_SetPrototype(m_ctx, m_prototypeObject, EventTarget::instance(m_context)->prototype()); }

  OBJECT_INSTANCE(Node);

  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  static JSClassID classId();

  static JSClassID classId(JSValue& value);

  static JSValue cloneNode(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue appendChild(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue remove(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue removeChild(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue insertBefore(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue replaceChild(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

 private:
  DEFINE_PROTOTYPE_PROPERTY(textContent);

  DEFINE_PROTOTYPE_READONLY_PROPERTY(isConnected);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(ownerDocument);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(firstChild);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(lastChild);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(parentNode);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(previousSibling);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(nextSibling);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(nodeType);

  DEFINE_PROTOTYPE_FUNCTION(cloneNode, 1);
  DEFINE_PROTOTYPE_FUNCTION(appendChild, 1);
  DEFINE_PROTOTYPE_FUNCTION(remove, 0);
  DEFINE_PROTOTYPE_FUNCTION(removeChild, 1);
  DEFINE_PROTOTYPE_FUNCTION(insertBefore, 2);
  DEFINE_PROTOTYPE_FUNCTION(replaceChild, 2);

  static void traverseCloneNode(JSContext* ctx, NodeInstance* baseNode, NodeInstance* targetNode);
  static JSValue copyNodeValue(JSContext* ctx, NodeInstance* node);
  friend ElementInstance;
  friend TextNodeInstance;
};

struct NodeJob {
  NodeInstance* nodeInstance;
  list_head link;
};

class NodeInstance : public EventTargetInstance {
 public:
  enum class NodeFlag : uint32_t { IsDocumentFragment = 1 << 0, IsTemplateElement = 1 << 1 };
  mutable std::set<NodeFlag> m_nodeFlags;
  bool hasNodeFlag(NodeFlag flag) const { return m_nodeFlags.size() != 0 && m_nodeFlags.find(flag) != m_nodeFlags.end(); }
  void setNodeFlag(NodeFlag flag) const { m_nodeFlags.insert(flag); }
  void removeNodeFlag(NodeFlag flag) const { m_nodeFlags.erase(flag); }

  NodeInstance() = delete;
  explicit NodeInstance(Node* node, NodeType nodeType, JSClassID classId, std::string name)
      : EventTargetInstance(node, classId, std::move(name)), m_document(m_context->document()), nodeType(nodeType) {}
  explicit NodeInstance(Node* node, NodeType nodeType, JSClassID classId, JSClassExoticMethods& exoticMethods, std::string name)
      : EventTargetInstance(node, classId, exoticMethods, name), m_document(m_context->document()), nodeType(nodeType) {}
  ~NodeInstance();
  bool isConnected();
  DocumentInstance* ownerDocument();
  NodeInstance* firstChild();
  NodeInstance* lastChild();
  NodeInstance* previousSibling();
  NodeInstance* nextSibling();
  void internalAppendChild(NodeInstance* node);
  void internalRemove();
  void internalClearChild();
  NodeInstance* internalRemoveChild(NodeInstance* node);
  JSValue internalInsertBefore(NodeInstance* node, NodeInstance* referenceNode);
  virtual JSValue internalGetTextContent();
  virtual void internalSetTextContent(JSValue content);
  JSValue internalReplaceChild(NodeInstance* newChild, NodeInstance* oldChild);

  void setParentNode(NodeInstance* parent);
  void removeParentNode();
  NodeType nodeType;
  JSValue parentNode{JS_NULL};
  JSValue childNodes{JS_NewArray(m_ctx)};

  NodeJob nodeLink{this};
  NodeJob documentLink{this};

  void refer();
  void unrefer();
  inline DocumentInstance* document() { return m_document; }

  virtual void _notifyNodeRemoved(NodeInstance* node);
  virtual void _notifyNodeInsert(NodeInstance* node);

 protected:
  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;

 private:
  DocumentInstance* m_document{nullptr};
  ObjectProperty m_childNodes{m_context, jsObject, "childNodes", childNodes};
  void ensureDetached(NodeInstance* node);
  friend DocumentInstance;
  friend Node;
  friend ElementInstance;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_NODE_H
