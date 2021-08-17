/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "anchor_element.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {
  
AnchorElement::AnchorElement(JSContext *context) : Element(context) {}

OBJECT_INSTANCE_IMPL(AnchorElement);

JSValue AnchorElement::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}
PROP_GETTER(AnchorElementInstance, href)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<AnchorElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getHref", 0, nullptr);
}
PROP_SETTER(AnchorElementInstance, href)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<AnchorElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setHref", 1, arguments);
}
PROP_GETTER(AnchorElementInstance, target)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<AnchorElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getTarget", 0, nullptr);
}
PROP_SETTER(AnchorElementInstance, target)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<AnchorElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setTarget", 1, arguments);
}

AnchorElementInstance::AnchorElementInstance(AnchorElement *element): ElementInstance(element, "CanvasElement", true) {}

}