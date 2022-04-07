/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "bindings/qjs/garbage_collected.h"
#include "container_node.h"

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

// bool isJavaScriptExtensionElementInstance(ExecutionContext* context, JSValue instance);

class Element : public ContainerNode {
  DEFINE_WRAPPERTYPEINFO();

 public:
  Element(ExecutingContext* context, const AtomicString& tag_name, Document*, ConstructionType = kCreateElement);

  bool hasAttribute(const AtomicString&) const;
  const AtomicString& getAttribute(const AtomicString&) const;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_ELEMENT_H
