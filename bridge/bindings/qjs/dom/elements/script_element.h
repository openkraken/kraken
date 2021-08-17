/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_SCRIPT_ELEMENT_H
#define KRAKENBRIDGE_SCRIPT_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {


class ScriptElement : public Element {
public:
  ScriptElement() = delete;
  explicit ScriptElement(JSContext *context);
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;
  
  OBJECT_INSTANCE(ScriptElement);
private:
  
};
class ScriptElementInstance : public ElementInstance {
public:
  ScriptElementInstance() = delete;
  explicit ScriptElementInstance(ScriptElement *element);
private:
  DEFINE_HOST_CLASS_PROPERTY(1, src)
};

}

#endif //KRAKENBRIDGE_SCRIPT_ELEMENTT_H
