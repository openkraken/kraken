/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ANCHOR_ELEMENT_H
#define KRAKENBRIDGE_ANCHOR_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {


class AnchorElement : public Element {
public:
  AnchorElement() = delete;
  explicit AnchorElement(JSContext *context);
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;
  
  OBJECT_INSTANCE(AnchorElement);
private:
  
};
class AnchorElementInstance : public ElementInstance {
public:
  AnchorElementInstance() = delete;
  explicit AnchorElementInstance(AnchorElement *element);
private:
  DEFINE_HOST_CLASS_PROPERTY(2, href, target)
};

}

#endif //KRAKENBRIDGE_ANCHOR_ELEMENTT_H
