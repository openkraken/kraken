/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_INPUT_ELEMENT_H
#define KRAKENBRIDGE_INPUT_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {


class InputElement : public Element {
public:
  InputElement() = delete;
  explicit InputElement(JSContext *context);
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;
  static JSValue focus(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue blur(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  OBJECT_INSTANCE(InputElement);
private:
  ObjectFunction m_focus{m_context, m_prototypeObject, "focus", focus, 0};
  ObjectFunction m_blur{m_context, m_prototypeObject, "blur", blur, 0};
};
class InputElementInstance : public ElementInstance {
public:
  InputElementInstance() = delete;
  explicit InputElementInstance(InputElement *element);
private:
  DEFINE_HOST_CLASS_PROPERTY(21, width, height, value, accept, autocomplete, autofocus, checked, disabled, min, max, minlength, maxlength, size, multiple, name, step, pattern, required, readonly, placeholder, type)
};

}

#endif //KRAKENBRIDGE_INPUT_ELEMENTT_H
