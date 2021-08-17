/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_element.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {
  
ScriptElement::ScriptElement(JSContext *context) : Element(context) {}

OBJECT_INSTANCE_IMPL(ScriptElement);

JSValue ScriptElement::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}
PROP_GETTER(ScriptElementInstance, src)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ScriptElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getSrc", 0, nullptr);
}
PROP_SETTER(ScriptElementInstance, src)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ScriptElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setSrc", 1, arguments);
}

ScriptElementInstance::ScriptElementInstance(ScriptElement *element): ElementInstance(element, "CanvasElement", true) {}

}