/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "bindings/qjs/garbage_collected.h"
#include "container_node.h"
#include "element_data.h"

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

  bool hasAttribute(const AtomicString&) const;
  const AtomicString& getAttribute(const AtomicString&) const;

  // Passing null as the second parameter removes the attribute when
  // calling either of these set methods.
  void setAttribute(const AtomicString&, const AtomicString& value);
  void setAttribute(const AtomicString&, const AtomicString& value, ExceptionState&);

  AtomicString TagName() const { return tag_name_; }

 protected:
  const ElementData* GetElementData() const { return &element_data_; }

 private:
  AtomicString tag_name_;
  ElementData element_data_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_ELEMENT_H
