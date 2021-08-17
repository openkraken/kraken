/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "object_element.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {
  
ObjectElement::ObjectElement(JSContext *context) : Element(context) {}

OBJECT_INSTANCE_IMPL(ObjectElement);

JSValue ObjectElement::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}
PROP_GETTER(ObjectElementInstance, type)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ObjectElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getType", 0, nullptr);
}
PROP_SETTER(ObjectElementInstance, type)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ObjectElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setType", 1, arguments);
}
PROP_GETTER(ObjectElementInstance, data)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ObjectElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getData", 0, nullptr);
}
PROP_SETTER(ObjectElementInstance, data)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ObjectElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setData", 1, arguments);
}
PROP_GETTER(ObjectElementInstance, currentData)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ObjectElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getCurrentData", 0, nullptr);
}
PROP_SETTER(ObjectElementInstance, currentData)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ObjectElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setCurrentData", 1, arguments);
}
PROP_GETTER(ObjectElementInstance, currentType)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ObjectElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getCurrentType", 0, nullptr);
}
PROP_SETTER(ObjectElementInstance, currentType)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ObjectElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setCurrentType", 1, arguments);
}

ObjectElementInstance::ObjectElementInstance(ObjectElement *element): ElementInstance(element, "CanvasElement", true) {}

}