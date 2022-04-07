/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_CONTAINER_NODE_H_
#define KRAKENBRIDGE_CORE_DOM_CONTAINER_NODE_H_

#include "node.h"
#include "bindings/qjs/gc_visitor.h"

namespace kraken {

class ContainerNode : public Node {
  ~ContainerNode() override;

  Node* firstChild() const { return first_child_; }
  Node* lastChild() const { return last_child_; }
  bool hasChildren() const { return first_child_; }
  bool HasChildren() const { return first_child_; }

  bool HasOneChild() const {
    return first_child_ && !first_child_->nextSibling();
  }
  bool HasOneTextChild() const {
    return HasOneChild() && first_child_->IsTextNode();
  }
  bool HasChildCount(unsigned) const;

  HTMLCollection* Children();

  unsigned CountChildren() const;

  Element* QuerySelector(const AtomicString& selectors, ExceptionState&);
  Element* QuerySelector(const AtomicString& selectors);
  StaticElementList* QuerySelectorAll(const AtomicString& selectors,
                                      ExceptionState&);
  StaticElementList* QuerySelectorAll(const AtomicString& selectors);

  Node* InsertBefore(Node* new_child, Node* ref_child, ExceptionState&);
  Node* InsertBefore(Node* new_child, Node* ref_child);
  Node* ReplaceChild(Node* new_child, Node* old_child, ExceptionState&);
  Node* ReplaceChild(Node* new_child, Node* old_child);
  Node* RemoveChild(Node* child, ExceptionState&);
  Node* RemoveChild(Node* child);
  Node* AppendChild(Node* new_child, ExceptionState&);
  Node* AppendChild(Node* new_child);
  bool EnsurePreInsertionValidity(const Node& new_child,
                                  const Node* next,
                                  const Node* old_child,
                                  ExceptionState&) const;

  Element* getElementById(const AtomicString& id) const;
  HTMLCollection* getElementsByTagName(const AtomicString&);
  HTMLCollection* getElementsByTagNameNS(const AtomicString& namespace_uri,
                                         const AtomicString& local_name);
  NodeList* getElementsByName(const AtomicString& element_name);
  HTMLCollection* getElementsByClassName(const AtomicString& class_names);
  RadioNodeList* GetRadioNodeList(const AtomicString&,
                                  bool only_match_img_elements = false);

  // These methods are only used during parsing.
  // They don't send DOM mutation events or accept DocumentFragments.
  void ParserAppendChild(Node*);
  void ParserRemoveChild(Node&);
  void ParserInsertBefore(Node* new_child, Node& ref_child);
  void ParserTakeAllChildrenFrom(ContainerNode&);

  void RemoveChildren(
      SubtreeModificationAction = kDispatchSubtreeModifiedEvent);

  void CloneChildNodesFrom(const ContainerNode&, CloneChildrenFlag);

  void AttachLayoutTree(AttachContext&) override;
  void DetachLayoutTree(bool performing_reattach = false) override;
  PhysicalRect BoundingBox() const final;
  void SetFocused(bool, mojom::blink::FocusType) override;
  void SetHasFocusWithinUpToAncestor(bool, Node* ancestor);
  void FocusStateChanged();
  void FocusVisibleStateChanged();
  void FocusWithinStateChanged();
  void SetDragged(bool) override;
  void RemovedFrom(ContainerNode& insertion_point) override;

  bool ChildrenOrSiblingsAffectedByFocus() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenOrSiblingsAffectedByFocus);
  }
  void SetChildrenOrSiblingsAffectedByFocus() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenOrSiblingsAffectedByFocus);
  }

  bool ChildrenOrSiblingsAffectedByFocusVisible() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenOrSiblingsAffectedByFocusVisible);
  }
  void SetChildrenOrSiblingsAffectedByFocusVisible() {
    SetRestyleFlag(
        DynamicRestyleFlags::kChildrenOrSiblingsAffectedByFocusVisible);
  }

  bool ChildrenOrSiblingsAffectedByFocusWithin() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenOrSiblingsAffectedByFocusWithin);
  }
  void SetChildrenOrSiblingsAffectedByFocusWithin() {
    SetRestyleFlag(
        DynamicRestyleFlags::kChildrenOrSiblingsAffectedByFocusWithin);
  }

  bool ChildrenOrSiblingsAffectedByHover() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenOrSiblingsAffectedByHover);
  }
  void SetChildrenOrSiblingsAffectedByHover() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenOrSiblingsAffectedByHover);
  }

  bool ChildrenOrSiblingsAffectedByActive() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenOrSiblingsAffectedByActive);
  }
  void SetChildrenOrSiblingsAffectedByActive() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenOrSiblingsAffectedByActive);
  }

  bool ChildrenOrSiblingsAffectedByDrag() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenOrSiblingsAffectedByDrag);
  }
  void SetChildrenOrSiblingsAffectedByDrag() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenOrSiblingsAffectedByDrag);
  }

  bool ChildrenAffectedByFirstChildRules() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenAffectedByFirstChildRules);
  }
  void SetChildrenAffectedByFirstChildRules() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenAffectedByFirstChildRules);
  }

  bool ChildrenAffectedByLastChildRules() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenAffectedByLastChildRules);
  }
  void SetChildrenAffectedByLastChildRules() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenAffectedByLastChildRules);
  }

  bool ChildrenAffectedByDirectAdjacentRules() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenAffectedByDirectAdjacentRules);
  }
  void SetChildrenAffectedByDirectAdjacentRules() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenAffectedByDirectAdjacentRules);
  }

  bool ChildrenAffectedByIndirectAdjacentRules() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenAffectedByIndirectAdjacentRules);
  }
  void SetChildrenAffectedByIndirectAdjacentRules() {
    SetRestyleFlag(
        DynamicRestyleFlags::kChildrenAffectedByIndirectAdjacentRules);
  }

  bool ChildrenAffectedByForwardPositionalRules() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenAffectedByForwardPositionalRules);
  }
  void SetChildrenAffectedByForwardPositionalRules() {
    SetRestyleFlag(
        DynamicRestyleFlags::kChildrenAffectedByForwardPositionalRules);
  }

  bool ChildrenAffectedByBackwardPositionalRules() const {
    return HasRestyleFlag(
        DynamicRestyleFlags::kChildrenAffectedByBackwardPositionalRules);
  }
  void SetChildrenAffectedByBackwardPositionalRules() {
    SetRestyleFlag(
        DynamicRestyleFlags::kChildrenAffectedByBackwardPositionalRules);
  }

  bool AffectedByFirstChildRules() const {
    return HasRestyleFlag(DynamicRestyleFlags::kAffectedByFirstChildRules);
  }
  void SetAffectedByFirstChildRules() {
    SetRestyleFlag(DynamicRestyleFlags::kAffectedByFirstChildRules);
  }

  bool AffectedByLastChildRules() const {
    return HasRestyleFlag(DynamicRestyleFlags::kAffectedByLastChildRules);
  }
  void SetAffectedByLastChildRules() {
    SetRestyleFlag(DynamicRestyleFlags::kAffectedByLastChildRules);
  }

  bool NeedsAdjacentStyleRecalc() const;

  // FIXME: These methods should all be renamed to something better than
  // "check", since it's not clear that they alter the style bits of siblings
  // and children.
  enum SiblingCheckType {
    kFinishedParsingChildren,
    kSiblingElementInserted,
    kSiblingElementRemoved
  };
  void CheckForSiblingStyleChanges(SiblingCheckType,
                                   Element* changed_element,
                                   Node* node_before_change,
                                   Node* node_after_change);
  void RecalcDescendantStyles(const StyleRecalcChange,
                              const StyleRecalcContext&);
  void RebuildChildrenLayoutTrees(WhitespaceAttacher&);
  void RebuildLayoutTreeForChild(Node* child, WhitespaceAttacher&);

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
    STACK_ALLOCATED();

   public:
    static ChildrenChange ForInsertion(Node& node,
                                       Node* unchanged_previous,
                                       Node* unchanged_next,
                                       ChildrenChangeSource by_parser) {
      ChildrenChange change = {node.IsElementNode()
                               ? ChildrenChangeType::kElementInserted
                               : ChildrenChangeType::kNonElementInserted,
                               by_parser,
                               &node,
                               unchanged_previous,
                               unchanged_next,
                               {},
                               String()};
      return change;
    }

    static ChildrenChange ForRemoval(Node& node,
                                     Node* previous_sibling,
                                     Node* next_sibling,
                                     ChildrenChangeSource by_parser) {
      ChildrenChange change = {node.IsElementNode()
                               ? ChildrenChangeType::kElementRemoved
                               : ChildrenChangeType::kNonElementRemoved,
                               by_parser,
                               &node,
                               previous_sibling,
                               next_sibling,
                               {},
                               String()};
      return change;
    }

    bool IsChildInsertion() const {
      return type == ChildrenChangeType::kElementInserted ||
          type == ChildrenChangeType::kNonElementInserted;
    }
    bool IsChildRemoval() const {
      return type == ChildrenChangeType::kElementRemoved ||
          type == ChildrenChangeType::kNonElementRemoved;
    }
    bool IsChildElementChange() const {
      return type == ChildrenChangeType::kElementInserted ||
          type == ChildrenChangeType::kElementRemoved;
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
    HeapVector<Member<Node>> removed_nodes;
    // |old_text| is mostly empty, only used for text node changes.
    const String& old_text;
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

  void Trace(Visitor*) const override;

 protected:
  ContainerNode(TreeScope*, ConstructionType = kCreateContainer);

  // |attr_name| and |owner_element| are only used for element attribute
  // modifications. |ChildrenChange| is either nullptr or points to a
  // ChildNode::ChildrenChange structure that describes the changes in the tree.
  // If non-null, blink may preserve caches that aren't affected by the change.
  void InvalidateNodeListCachesInAncestors(const QualifiedName* attr_name,
                                           Element* attribute_owner_element,
                                           const ChildrenChange*);

  void SetFirstChild(Node* child) {
    first_child_ = child;
  }
  void SetLastChild(Node* child) {
    last_child_ = child;
  }

  // Utility functions for NodeListsNodeData API.
  template <typename Collection>
  Collection* EnsureCachedCollection(CollectionType);
  template <typename Collection>
  Collection* EnsureCachedCollection(CollectionType, const AtomicString& name);
  template <typename Collection>
  Collection* EnsureCachedCollection(CollectionType,
                                     const AtomicString& namespace_uri,
                                     const AtomicString& local_name);
  template <typename Collection>
  Collection* CachedCollection(CollectionType);

 private:
  bool IsContainerNode() const =
  delete;  // This will catch anyone doing an unnecessary check.
  bool IsTextNode() const =
  delete;  // This will catch anyone doing an unnecessary check.

  NodeListsNodeData& EnsureNodeLists();
  void RemoveBetween(Node* previous_child, Node* next_child, Node& old_child);
  // Inserts the specified nodes before |next|.
  // |next| may be nullptr.
  // |post_insertion_notification_targets| must not be nullptr.
  template <typename Functor>
  void InsertNodeVector(const NodeVector&,
                        Node* next,
                        const Functor&,
                        NodeVector* post_insertion_notification_targets);
  void DidInsertNodeVector(
      const NodeVector&,
      Node* next,
      const NodeVector& post_insertion_notification_targets);
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

  void NotifyNodeInserted(Node&,
                          ChildrenChangeSource = ChildrenChangeSource::kAPI);
  void NotifyNodeInsertedInternal(
      Node&,
      NodeVector& post_insertion_notification_targets);
  void NotifyNodeRemoved(Node&);

  bool HasRestyleFlag(DynamicRestyleFlags mask) const {
    return HasRareData() && HasRestyleFlagInternal(mask);
  }
  bool HasRestyleFlags() const {
    return HasRareData() && HasRestyleFlagsInternal();
  }
  void SetRestyleFlag(DynamicRestyleFlags);
  bool HasRestyleFlagInternal(DynamicRestyleFlags) const;
  bool HasRestyleFlagsInternal() const;

  bool RecheckNodeInsertionStructuralPrereq(const NodeVector&,
                                            const Node* next,
                                            ExceptionState&);
  inline bool CheckParserAcceptChild(const Node& new_child) const;
  inline bool IsHostIncludingInclusiveAncestorOfThis(const Node&,
                                                     ExceptionState&) const;
  inline bool IsChildTypeAllowed(const Node& child) const;

  Node* first_child_;
  Node* last_child_;
};

}

#endif  // KRAKENBRIDGE_CORE_DOM_CONTAINER_NODE_H_
