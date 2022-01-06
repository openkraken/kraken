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

const int kDOMNodeTypeShift = 2;
const int kElementNamespaceTypeShift = 4;
enum class NodeType { ELEMENT_NODE = 1, TEXT_NODE = 3, COMMENT_NODE = 8, DOCUMENT_NODE = 9, DOCUMENT_TYPE_NODE = 10, DOCUMENT_FRAGMENT_NODE = 11 };

class NodeInstance;
class ElementInstance;
class DocumentInstance;
class TextNodeInstance;
class NodeList;

// This constant controls how much buffer is initially allocated
// for a Node Vector that is used to store child Nodes of a given Node.
const int kInitialNodeVectorSize = 11;
using NodeVector = std::vector<NodeInstance*>;

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
  enum NodeFlag : uint32_t {
    // Node type flags. These never change once created.
    kIsContainerFlag = 1 << 3,
    kDOMNodeTypeMask = 0x3 << kDOMNodeTypeShift,
    kElementNamespaceTypeMask = 0x3 << kElementNamespaceTypeShift,

    // Tree state flags. These change when the element is added/removed
    // from a DOM tree.
    kIsConnectedFlag = 1 << 4,
  };
  uint32_t m_nodeFlags;
  FORCE_INLINE bool getFlag(NodeFlag mask) const { return m_nodeFlags & mask; }
  void setFlag(bool v, NodeFlag mask) { m_nodeFlags = (m_nodeFlags & ~mask) | (-(int32_t)v & mask); }
  void setFlag(NodeFlag mask) { m_nodeFlags |= mask; }
  void clearFlag(NodeFlag mask) { m_nodeFlags &= ~mask; }

  enum class DOMNodeType : uint32_t {
    kElement = 0,
    kText = 1 << kDOMNodeTypeShift,
    kDocumentFragment = 2 << kDOMNodeTypeShift,
    kOther = 3 << kDOMNodeTypeShift,
  };
  FORCE_INLINE DOMNodeType getDOMNodeType() const { return static_cast<DOMNodeType>(m_nodeFlags & kDOMNodeTypeMask); }

  enum class ElementNamespaceType : uint32_t {
    kHTML = 0,
    kMathML = 1 << kElementNamespaceTypeShift,
    kSVG = 2 << kElementNamespaceTypeShift,
    kOther = 3 << kElementNamespaceTypeShift,
  };
  FORCE_INLINE ElementNamespaceType getElementNamespaceType() const { return static_cast<ElementNamespaceType>(m_nodeFlags & kElementNamespaceTypeMask); }

  NodeInstance() = delete;
  ~NodeInstance();
  bool isConnected() const;
  DocumentInstance* ownerDocument();
  inline NodeInstance* firstChild();
  NodeInstance* lastChild();
  NodeInstance* previousSibling();
  NodeInstance* nextSibling();
  NodeInstance* internalAppendChild(NodeInstance* node, JSValue* exception);
  void internalRemove();
  void internalClearChild();
  NodeInstance* internalRemoveChild(NodeInstance* node);
  JSValue internalInsertBefore(NodeInstance* node, NodeInstance* referenceNode);
  virtual JSValue internalGetTextContent();
  virtual void internalSetTextContent(JSValue content);
  JSValue internalReplaceChild(NodeInstance* newChild, NodeInstance* oldChild);

  bool isDescendantOf(const NodeInstance*) const;
  bool contains(const NodeInstance*) const;

  NodeInstance* parentNode() const;
  NodeInstance& treeRoot() const;

  // TODO: remove this
  void setParentNode(NodeInstance* parent);
  void removeParentNode();

  NodeList* childNodes();
  NodeJob nodeLink{this};

  void refer();
  void unrefer();
  inline DocumentInstance* document() { return m_document; }

  virtual void _notifyNodeRemoved(NodeInstance* node);
  virtual void _notifyNodeInsert(NodeInstance* node);

  FORCE_INLINE bool isElementNode() const { return getDOMNodeType() == DOMNodeType::kElement; }
  FORCE_INLINE bool isDocumentFragment() const { return getDOMNodeType() == DOMNodeType::kDocumentFragment; }
  FORCE_INLINE bool isTextNode() const { return getDOMNodeType() == DOMNodeType::kText; }
  FORCE_INLINE bool isContainerNode() const { return getFlag(kIsContainerFlag); }

 protected:
  enum ConstructionType {
    kCreateText = static_cast<NodeFlag>(NodeType::TEXT_NODE) | static_cast<NodeFlag>(DOMNodeType::kText),
    kCreateContainer = static_cast<NodeFlag>(kIsContainerFlag) | static_cast<NodeFlag>(DOMNodeType::kOther),
    kCreateElement = kIsContainerFlag | static_cast<NodeFlag>(DOMNodeType::kElement) | static_cast<NodeFlag>(ElementNamespaceType::kOther),
    kCreateDocumentFragment = kIsContainerFlag | static_cast<NodeFlag>(DOMNodeType::kDocumentFragment) | static_cast<NodeFlag>(ElementNamespaceType::kOther),
    kCreateHTMLElement = kIsContainerFlag | static_cast<NodeFlag>(DOMNodeType::kElement) | static_cast<NodeFlag>(ElementNamespaceType::kHTML),
    kCreateDocument = kCreateContainer | kIsConnectedFlag,
  };
  explicit NodeInstance(Node* node, ConstructionType type, JSClassID classId, std::string name)
      : EventTargetInstance(node, classId, std::move(name)), m_document(m_context->document()), m_nodeFlags(type) {}
  explicit NodeInstance(Node* node, ConstructionType type, JSClassID classId, JSClassExoticMethods& exoticMethods, std::string name)
      : EventTargetInstance(node, classId, exoticMethods, name), m_document(m_context->document()), m_nodeFlags(type) {}

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;

 private:
  // ensurePreInsertionValidity() is an implementation of step 2 to 6 of
  // https://dom.spec.whatwg.org/#concept-node-ensure-pre-insertion-validity and
  // https://dom.spec.whatwg.org/#concept-node-replace .
  bool ensurePreInsertionValidity(const NodeInstance& newChild, const NodeInstance* next, const NodeInstance* oldChild, JSValue* exception) const;

  // Returns true if |new_child| contains this node. In that case,
  // https://dom.spec.whatwg.org/#concept-tree-host-including-inclusive-ancestor
  bool isHostIncludingInclusiveAncestorOfThis(const NodeInstance& newChild, JSValue* exception) const;

  DocumentInstance* m_document{nullptr};
  NodeList* m_nodeList{nullptr};

  NodeInstance* m_parent{nullptr};

  NodeInstance* m_previousSibling{nullptr};
  NodeInstance* m_nextSibling{nullptr};

  // TODO: refactor these properties to ContainerNode.
  NodeInstance* m_firstChild{nullptr};
  NodeInstance* m_lastChild{nullptr};

  void ensureDetached(NodeInstance* node);
  friend DocumentInstance;
  friend Node;
  friend ElementInstance;
};

inline void getChildNodes(NodeInstance& node, NodeVector& nodes) {
  assert(!nodes.empty());
  for (NodeInstance* child = node.firstChild(); child; child = child->nextSibling())
    nodes.emplace_back(child);
}

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_NODE_H
