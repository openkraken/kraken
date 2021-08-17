/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_OBJECT_ELEMENT_H
#define KRAKENBRIDGE_OBJECT_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {


class ObjectElement : public Element {
public:
  ObjectElement() = delete;
  explicit ObjectElement(JSContext *context);
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;
  
  OBJECT_INSTANCE(ObjectElement);
private:
  
};
class ObjectElementInstance : public ElementInstance {
public:
  ObjectElementInstance() = delete;
  explicit ObjectElementInstance(ObjectElement *element);
private:
  DEFINE_HOST_CLASS_PROPERTY(4, type, data, currentData, currentType)
};

}

#endif //KRAKENBRIDGE_OBJECT_ELEMENTT_H
