/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "bindings/qjs/garbage_collected.h"
#include "container_node.h"
#include "legacy/bounding_client_rect.h"
#include "legacy/element_attributes.h"

namespace kraken {

struct NativeBoundingClientRect {
  double x;
  double y;
  double width;
  double height;
  double top;
  double right;
  double bottom;
  double left;
};

class Element : public ContainerNode {
  DEFINE_WRAPPERTYPEINFO();

 public:
  Element(Document* document, const AtomicString& tag_name, ConstructionType = kCreateElement);

  bool hasAttribute(const AtomicString&, ExceptionState& exception_state) const;
  AtomicString getAttribute(const AtomicString&, ExceptionState& exception_state) const;

  // Passing null as the second parameter removes the attribute when
  // calling either of these set methods.
  void setAttribute(const AtomicString&, const AtomicString& value);
  void setAttribute(const AtomicString&, const AtomicString& value, ExceptionState&);
  void removeAttribute(const AtomicString&, ExceptionState& exception_state);
  BoundingClientRect* getBoundingClientRect();

  //  static JSValue getBoundingClientRect(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  //  static JSValue removeAttribute(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  //  static JSValue toBlob(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  //  static JSValue click(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  //  static JSValue scroll(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  //  static JSValue scrollBy(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  AtomicString TagName() const { return tag_name_; }

 protected:
 private:
  void _notifyNodeRemoved(Node* node);
  void _notifyChildRemoved();
  void _notifyNodeInsert(Node* insertNode);
  void _notifyChildInsert();
  void _didModifyAttribute(const AtomicString& name, const AtomicString& oldId, const AtomicString& newId);
  void _beforeUpdateId(JSValue oldIdValue, JSValue newIdValue);

  ElementAttributes* attributes_{nullptr};
  AtomicString tag_name_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_ELEMENT_H
