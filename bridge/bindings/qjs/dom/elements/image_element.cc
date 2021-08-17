/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "image_element.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {
  
ImageElement::ImageElement(JSContext *context) : Element(context) {}

OBJECT_INSTANCE_IMPL(ImageElement);

JSValue ImageElement::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}
PROP_GETTER(ImageElementInstance, width)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getWidth", 0, nullptr);
}
PROP_SETTER(ImageElementInstance, width)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setWidth", 1, arguments);
}
PROP_GETTER(ImageElementInstance, height)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getHeight", 0, nullptr);
}
PROP_SETTER(ImageElementInstance, height)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setHeight", 1, arguments);
}
PROP_GETTER(ImageElementInstance, naturalWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getNaturalWidth", 0, nullptr);
}
PROP_SETTER(ImageElementInstance, naturalWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setNaturalWidth", 1, arguments);
}
PROP_GETTER(ImageElementInstance, naturalHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getNaturalHeight", 0, nullptr);
}
PROP_SETTER(ImageElementInstance, naturalHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setNaturalHeight", 1, arguments);
}
PROP_GETTER(ImageElementInstance, src)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getSrc", 0, nullptr);
}
PROP_SETTER(ImageElementInstance, src)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setSrc", 1, arguments);
}
PROP_GETTER(ImageElementInstance, loading)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getLoading", 0, nullptr);
}
PROP_SETTER(ImageElementInstance, loading)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ImageElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setLoading", 1, arguments);
}

ImageElementInstance::ImageElementInstance(ImageElement *element): ElementInstance(element, "CanvasElement", true) {}

}