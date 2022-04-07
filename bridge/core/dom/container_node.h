/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_CONTAINER_NODE_H_
#define KRAKENBRIDGE_CORE_DOM_CONTAINER_NODE_H_

#include <vector>
#include "bindings/qjs/gc_visitor.h"
#include "node.h"

namespace kraken {

class HTMLCollection;

// This constant controls how much buffer is initially allocated
// for a Node Vector that is used to store child Nodes of a given Node.
// FIXME: Optimize the value.
const int kInitialNodeVectorSize = 11;
using NodeVector = std::vector<Node*>;

class ContainerNode : public Node {
 public:
  ~ContainerNode() override;

  Node* firstChild() const { return first_child_; }
  Node* lastChild() const { return last_child_; }
  bool hasChildren() const { return first_child_; }
  bool HasChildren() const { return first_child_; }

  bool HasOneChild() const { return first_child_ && !first_child_->nextSibling(); }
  bool HasOneTextChild() const { return HasOneChild() && first_child_->IsTextNode(); }
  bool HasChildCount(unsigned) const;

  HTMLCollection* Children();

  unsigned CountChildren() const;

  Node* InsertBefore(Node* new_child, Node* ref_child, ExceptionState&);
  Node* ReplaceChild(Node* new_child, Node* old_child, ExceptionState&);
  Node* RemoveChild(Node* child, ExceptionState&);
  Node* AppendChild(Node* new_child, ExceptionState&);
  bool EnsurePreInsertionValidity(const Node& new_child,
                                  const Node* next,
                                  const Node* old_child,
                                  ExceptionState&) const;

  // These methods are only used during parsing.
  // They don't send DOM mutation events or accept DocumentFragments.
  void ParserAppendChild(Node*);
  void ParserRemoveChild(Node&);
  void ParserInsertBefore(Node* new_child, Node& ref_child);
  void ParserTakeAllChildrenFrom(ContainerNode&);

  void RemoveChildren();

  // FIXME: These methods should all be renamed to something better than
  // "check", since it's not clear that they alter the style bits of siblings
  // and children.
  enum SiblingCheckType { kFinishedParsingChildren, kSiblingElementInserted, kSiblingElementRemoved };

  // -----------------------------------------------------------------------------
  // Notification of document structure changes (see core/dom/node.h for more
  // notification methods)

  enum class ChildrenChangeType : uint8_t {
    kElementInserted,
    kNonElementInserted,
    kElementRemoved,
    kNonElementRemoved,
    kAllChildrenRemoved,
    kTextChanged
  };
  enum class ChildrenChangeSource : uint8_t { kAPI, kParser };
  struct ChildrenChange {
   public:
    static ChildrenChange ForInsertion(Node& node,
                                       Node* unchanged_previous,
                                       Node* unchanged_next,
                                       ChildrenChangeSource by_parser) {
      ChildrenChange change = {
          node.IsElementNode() ? ChildrenChangeType::kElementInserted : ChildrenChangeType::kNonElementInserted,
          by_parser,
          &node,
          unchanged_previous,
          unchanged_next,
          {},
          ""};
      return change;
    }

    static ChildrenChange ForRemoval(Node& node,
                                     Node* previous_sibling,
                                     Node* next_sibling,
                                     ChildrenChangeSource by_parser) {
      ChildrenChange change = {
          node.IsElementNode() ? ChildrenChangeType::kElementRemoved : ChildrenChangeType::kNonElementRemoved,
          by_parser,
          &node,
          previous_sibling,
          next_sibling,
          {},
          ""};
      return change;
    }

    bool IsChildInsertion() const {
      return type == ChildrenChangeType::kElementInserted || type == ChildrenChangeType::kNonElementInserted;
    }
    bool IsChildRemoval() const {
      return type == ChildrenChangeType::kElementRemoved || type == ChildrenChangeType::kNonElementRemoved;
    }
    bool IsChildElementChange() const {
      return type == ChildrenChangeType::kElementInserted || type == ChildrenChangeType::kElementRemoved;
    }

    bool ByParser() const { return by_parser == ChildrenChangeSource::kParser; }

    ChildrenChangeType type;
    ChildrenChangeSource by_parser;
    Node* sibling_changed = nullptr;
    // |siblingBeforeChange| is
    //  - siblingChanged.previousSibling before node removal
    //  - siblingChanged.previousSibling after single node insertion
    //  - previousSibling of the first inserted node after multiple node
    //    insertion
    Node* sibling_before_change = nullptr;
    // |siblingAfterChange| is
    //  - siblingChanged.nextSibling before node removal
    //  - siblingChanged.nextSibling after single node insertion
    //  - nextSibling of the last inserted node after multiple node insertion.
    Node* sibling_after_change = nullptr;
    // List of removed nodes for ChildrenChangeType::kAllChildrenRemoved.
    // Only populated if ChildrenChangedAllChildrenRemovedNeedsList() returns
    // true.
    std::vector<Node*> removed_nodes;
    // |old_text| is mostly empty, only used for text node changes.
    const std::string& old_text;
  };

  // Notifies the node that it's list of children have changed (either by adding
  // or removing child nodes), or a child node that is of the type
  // kCdataSectionNode, kTextNode or kCommentNode has changed its value.
  //
  // ChildrenChanged() implementations may modify the DOM tree, and may dispatch
  // synchronous events.
  virtual void ChildrenChanged(const ChildrenChange&);

  // Provides ChildrenChange::removed_nodes for kAllChildrenRemoved.
  virtual bool ChildrenChangedAllChildrenRemovedNeedsList() const;

  virtual bool ChildrenCanHaveStyle() const { return true; }

  void Trace(GCVisitor* visitor) const override;

 protected:
  ContainerNode(Document* document, ConstructionType = kCreateContainer);

  void SetFirstChild(Node* child) { first_child_ = child; }
  void SetLastChild(Node* child) { last_child_ = child; }

 private:
  bool IsContainerNode() const = delete;  // This will catch anyone doing an unnecessary check.
  bool IsTextNode() const = delete;       // This will catch anyone doing an unnecessary check.
  void RemoveBetween(Node* previous_child, Node* next_child, Node& old_child);
  // Inserts the specified nodes before |next|.
  // |next| may be nullptr.
  // |post_insertion_notification_targets| must not be nullptr.
  template <typename Functor>
  void InsertNodeVector(const NodeVector&, Node* next, const Functor&, NodeVector* post_insertion_notification_targets);
  void DidInsertNodeVector(const NodeVector&, Node* next, const NodeVector& post_insertion_notification_targets);

  class AdoptAndInsertBefore;
  class AdoptAndAppendChild;
  friend class AdoptAndInsertBefore;
  friend class AdoptAndAppendChild;

  void InsertBeforeCommon(Node& next_child, Node& new_child);
  void AppendChildCommon(Node& child);
  void WillRemoveChildren();
  void WillRemoveChild(Node& child);
  void RemoveDetachedChildrenInContainer(ContainerNode&);
  void AddChildNodesToDeletionQueue(Node*&, Node*&, ContainerNode&);

  void NotifyNodeRemoved(Node&);

  inline bool IsChildTypeAllowed(const Node& child) const;

  Node* first_child_;
  Node* last_child_;
};

inline Node* Node::firstChild() const {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (!this_node)
    return nullptr;
  return this_node->firstChild();
}

inline Node* Node::lastChild() const {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (!this_node) {
    return nullptr;
  }
  return this_node->lastChild();
}

inline bool ContainerNode::HasChildCount(unsigned count) const {
  Node* child = first_child_;
  while (count && child) {
    child = child->nextSibling();
    --count;
  }
  return !count && !child;
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_CONTAINER_NODE_H_
