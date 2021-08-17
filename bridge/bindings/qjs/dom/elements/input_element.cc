/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "input_element.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {
  
InputElement::InputElement(JSContext *context) : Element(context) {}

OBJECT_INSTANCE_IMPL(InputElement);

JSValue InputElement::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}
PROP_GETTER(InputElementInstance, width)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getWidth", 0, nullptr);
}
PROP_SETTER(InputElementInstance, width)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setWidth", 1, arguments);
}
PROP_GETTER(InputElementInstance, height)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getHeight", 0, nullptr);
}
PROP_SETTER(InputElementInstance, height)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setHeight", 1, arguments);
}
PROP_GETTER(InputElementInstance, value)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getValue", 0, nullptr);
}
PROP_SETTER(InputElementInstance, value)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setValue", 1, arguments);
}
PROP_GETTER(InputElementInstance, accept)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getAccept", 0, nullptr);
}
PROP_SETTER(InputElementInstance, accept)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setAccept", 1, arguments);
}
PROP_GETTER(InputElementInstance, autocomplete)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getAutocomplete", 0, nullptr);
}
PROP_SETTER(InputElementInstance, autocomplete)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setAutocomplete", 1, arguments);
}
PROP_GETTER(InputElementInstance, autofocus)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getAutofocus", 0, nullptr);
}
PROP_SETTER(InputElementInstance, autofocus)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setAutofocus", 1, arguments);
}
PROP_GETTER(InputElementInstance, checked)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getChecked", 0, nullptr);
}
PROP_SETTER(InputElementInstance, checked)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setChecked", 1, arguments);
}
PROP_GETTER(InputElementInstance, disabled)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getDisabled", 0, nullptr);
}
PROP_SETTER(InputElementInstance, disabled)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setDisabled", 1, arguments);
}
PROP_GETTER(InputElementInstance, min)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getMin", 0, nullptr);
}
PROP_SETTER(InputElementInstance, min)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setMin", 1, arguments);
}
PROP_GETTER(InputElementInstance, max)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getMax", 0, nullptr);
}
PROP_SETTER(InputElementInstance, max)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setMax", 1, arguments);
}
PROP_GETTER(InputElementInstance, minlength)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getMinlength", 0, nullptr);
}
PROP_SETTER(InputElementInstance, minlength)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setMinlength", 1, arguments);
}
PROP_GETTER(InputElementInstance, maxlength)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getMaxlength", 0, nullptr);
}
PROP_SETTER(InputElementInstance, maxlength)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setMaxlength", 1, arguments);
}
PROP_GETTER(InputElementInstance, size)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getSize", 0, nullptr);
}
PROP_SETTER(InputElementInstance, size)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setSize", 1, arguments);
}
PROP_GETTER(InputElementInstance, multiple)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getMultiple", 0, nullptr);
}
PROP_SETTER(InputElementInstance, multiple)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setMultiple", 1, arguments);
}
PROP_GETTER(InputElementInstance, name)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getName", 0, nullptr);
}
PROP_SETTER(InputElementInstance, name)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setName", 1, arguments);
}
PROP_GETTER(InputElementInstance, step)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getStep", 0, nullptr);
}
PROP_SETTER(InputElementInstance, step)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setStep", 1, arguments);
}
PROP_GETTER(InputElementInstance, pattern)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getPattern", 0, nullptr);
}
PROP_SETTER(InputElementInstance, pattern)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setPattern", 1, arguments);
}
PROP_GETTER(InputElementInstance, required)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getRequired", 0, nullptr);
}
PROP_SETTER(InputElementInstance, required)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setRequired", 1, arguments);
}
PROP_GETTER(InputElementInstance, readonly)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getReadonly", 0, nullptr);
}
PROP_SETTER(InputElementInstance, readonly)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setReadonly", 1, arguments);
}
PROP_GETTER(InputElementInstance, placeholder)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getPlaceholder", 0, nullptr);
}
PROP_SETTER(InputElementInstance, placeholder)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setPlaceholder", 1, arguments);
}
PROP_GETTER(InputElementInstance, type)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getType", 0, nullptr);
}
PROP_SETTER(InputElementInstance, type)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setType", 1, arguments);
}
JSValue InputElement::focus(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {

  getDartMethod()->flushUICommand();

  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("focus", 0, nullptr);
}
JSValue InputElement::blur(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {

  getDartMethod()->flushUICommand();

  auto *element = static_cast<InputElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("blur", 0, nullptr);
}
InputElementInstance::InputElementInstance(InputElement *element): ElementInstance(element, "CanvasElement", true) {}

}