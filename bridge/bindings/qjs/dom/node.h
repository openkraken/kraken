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

class Element;
class Document;
class DocumentFragment;

void bindNode(std::unique_ptr<ExecutionContext>& context);

enum NodeType { ELEMENT_NODE = 1, TEXT_NODE = 3, COMMENT_NODE = 8, DOCUMENT_NODE = 9, DOCUMENT_TYPE_NODE = 10, DOCUMENT_FRAGMENT_NODE = 11 };

class Node;
class TextNode;
class Document;

struct NodeJob {
  Node* nodeInstance;
  list_head link;
};

class Node : public EventTarget {
 public:
  static JSClassID classId;
  static JSValue constructor(ExecutionContext* context);
  static JSValue prototype(ExecutionContext* context);
  static Node* create(JSContext* ctx);

  DEFINE_FUNCTION(cloneNode);
  DEFINE_FUNCTION(appendChild);
  DEFINE_FUNCTION(remove);
  DEFINE_FUNCTION(removeChild);
  DEFINE_FUNCTION(insertBefore);
  DEFINE_FUNCTION(replaceChild);

  DEFINE_PROTOTYPE_PROPERTY(textContent);

  DEFINE_PROTOTYPE_READONLY_PROPERTY(isConnected);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(ownerDocument);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(firstChild);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(lastChild);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(parentNode);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(previousSibling);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(nextSibling);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(nodeType);

  enum class NodeFlag : uint32_t { IsDocumentFragment = 1 << 0, IsTemplateElement = 1 << 1 };
  mutable std::set<NodeFlag> m_nodeFlags;
  bool hasNodeFlag(NodeFlag flag) const { return m_nodeFlags.size() != 0 && m_nodeFlags.find(flag) != m_nodeFlags.end(); }
  void setNodeFlag(NodeFlag flag) const { m_nodeFlags.insert(flag); }
  void removeNodeFlag(NodeFlag flag) const { m_nodeFlags.erase(flag); }

  bool isConnected();
  Document* ownerDocument();
  Node* firstChild();
  Node* lastChild();
  Node* previousSibling();
  Node* nextSibling();

  void setParentNode(Node* parent);
  void removeParentNode();
  NodeType nodeType;
  JSValue parentNode{JS_NULL};
  JSValue childNodes{JS_NewArray(m_ctx)};

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;

protected:
  NodeJob nodeLink{this};

  void refer();
  void unrefer();
  void internalAppendChild(Node* node);
  void internalRemove();
  void internalClearChild();
  Node* internalRemoveChild(Node* node);
  JSValue internalInsertBefore(Node* node, Node* referenceNode);
  virtual JSValue internalGetTextContent();
  virtual void internalSetTextContent(JSValue content);
  JSValue internalReplaceChild(Node* newChild, Node* oldChild);

  virtual void _notifyNodeRemoved(Node* node);
  virtual void _notifyNodeInsert(Node* node);
private:
  ObjectProperty m_childNodes{context(), jsObject, "childNodes", childNodes};
  void ensureDetached(Node* node);

  static void traverseCloneNode(JSContext* ctx, Node* baseNode, Node* targetNode);
  static JSValue copyNodeValue(JSContext* ctx, Node* node);
};

auto nodeCreator = [](JSContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags) -> JSValue {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
};

const WrapperTypeInfo nodeTypeInfo = {
    "Node",
    &eventTargetTypeInfo,
    nodeCreator
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_NODE_H
