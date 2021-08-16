/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CANVAS_ELEMENT_H
#define KRAKENBRIDGE_CANVAS_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {

struct NativeCanvasRenderingContext2D {
  CallNativeMethods callNativeMethods{nullptr};
};

class CanvasRenderingContext2D : public HostObject {
public:
  CanvasRenderingContext2D() = delete;
  explicit CanvasRenderingContext2D(JSContext *context, NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);
private:
  DEFINE_HOST_OBJECT_PROPERTY(2, direction, font);
  NativeCanvasRenderingContext2D *m_nativeContext2d{nullptr};
};

class CanvasElement : public Element {
public:
  CanvasElement() = delete;
  explicit CanvasElement(JSContext *context);
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;

  static JSValue getContext(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

  ObjectFunction m_getContext{m_context, m_prototypeObject, "getContext", getContext, 2};
private:
};

class CanvasElementInstance : public ElementInstance {
public:
  CanvasElementInstance() = delete;
  explicit CanvasElementInstance(CanvasElement *canvasElement);
private:
  DEFINE_HOST_CLASS_PROPERTY(2, width, height);
};

}


#endif //KRAKENBRIDGE_CANVAS_ELEMENT_H
