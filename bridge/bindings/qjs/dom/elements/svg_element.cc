/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "svg_element.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {
  
SVGElement::SVGElement(JSContext *context) : Element(context) {}

OBJECT_INSTANCE_IMPL(SVGElement);

JSValue SVGElement::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}


SVGElementInstance::SVGElementInstance(SVGElement *element): ElementInstance(element, "CanvasElement", true) {}

}