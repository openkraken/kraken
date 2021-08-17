/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_SVG_ELEMENT_H
#define KRAKENBRIDGE_SVG_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {


class SVGElement : public Element {
public:
  SVGElement() = delete;
  explicit SVGElement(JSContext *context);
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;
  
  OBJECT_INSTANCE(SVGElement);
private:
  
};
class SVGElementInstance : public ElementInstance {
public:
  SVGElementInstance() = delete;
  explicit SVGElementInstance(SVGElement *element);
private:
  
};

}

#endif //KRAKENBRIDGE_SVG_ELEMENTT_H
