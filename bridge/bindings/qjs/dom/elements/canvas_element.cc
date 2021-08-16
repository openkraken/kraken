/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "canvas_element.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {

CanvasElement::CanvasElement(JSContext *context) : Element(context) {
}

JSValue CanvasElement::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}

JSValue CanvasElement::getContext(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute 'getContext' on 'CanvasElement': 1 argument required, but %d present.",
                             argc);
  }

  getDartMethod()->flushUICommand();
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };

  auto *element = static_cast<CanvasElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getContext", 1, arguments);
}

CanvasRenderingContext2D::CanvasRenderingContext2D(JSContext *context,
                                                   NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D)
  : HostObject(context, "CanvasRenderingContext2D"), m_nativeContext2d(nativeCanvasRenderingContext2D) {
}

PROP_GETTER(CanvasElementInstance, width)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("width", 0, nullptr);
}
PROP_SETTER(CanvasElementInstance, width)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(CanvasElementInstance, height)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("width", 0, nullptr);
}
PROP_SETTER(CanvasElementInstance, height)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}


CanvasElementInstance::CanvasElementInstance(CanvasElement *canvasElement) : ElementInstance(canvasElement, "CanvasElement", true) {

}
}
