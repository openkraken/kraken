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
  explicit CanvasRenderingContext2D(JSContext *context, NativeCanvasRenderingContext2D *nativePtr);

  JSValue callNativeMethods(const char* method, int32_t argc,
                          NativeValue *argv);


  static JSValue arc(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue arcTo(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue beginPath(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue bezierCurveTo(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue clearRect(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue closePath(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue clip(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue drawImage(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue ellipse(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue fill(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue fillRect(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue fillText(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue lineTo(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue moveTo(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue rect(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue restore(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue resetTransform(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue rotate(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue quadraticCurveTo(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue stroke(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue strokeRect(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue save(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue scale(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue strokeText(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue setTransform(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue transform(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue translate(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

private:
  NativeCanvasRenderingContext2D *m_nativePtr{nullptr};
  DEFINE_HOST_OBJECT_PROPERTY(11, fillStyle, direction, font, strokeStyle, lineCap, lineDashOffset, lineJoin, lineWidth, miterLimit, textAlign, textBaseline)

  ObjectFunction m_arc{m_context, jsObject, "arc", arc, 6};
  ObjectFunction m_arcTo{m_context, jsObject, "arcTo", arcTo, 5};
  ObjectFunction m_beginPath{m_context, jsObject, "beginPath", beginPath, 0};
  ObjectFunction m_bezierCurveTo{m_context, jsObject, "bezierCurveTo", bezierCurveTo, 6};
  ObjectFunction m_clearRect{m_context, jsObject, "clearRect", clearRect, 4};
  ObjectFunction m_closePath{m_context, jsObject, "closePath", closePath, 0};
  ObjectFunction m_clip{m_context, jsObject, "clip", clip, 1};
  ObjectFunction m_drawImage{m_context, jsObject, "drawImage", drawImage, 9};
  ObjectFunction m_ellipse{m_context, jsObject, "ellipse", ellipse, 8};
  ObjectFunction m_fill{m_context, jsObject, "fill", fill, 1};
  ObjectFunction m_fillRect{m_context, jsObject, "fillRect", fillRect, 4};
  ObjectFunction m_fillText{m_context, jsObject, "fillText", fillText, 4};
  ObjectFunction m_lineTo{m_context, jsObject, "lineTo", lineTo, 2};
  ObjectFunction m_moveTo{m_context, jsObject, "moveTo", moveTo, 2};
  ObjectFunction m_rect{m_context, jsObject, "rect", rect, 4};
  ObjectFunction m_restore{m_context, jsObject, "restore", restore, 0};
  ObjectFunction m_resetTransform{m_context, jsObject, "resetTransform", resetTransform, 0};
  ObjectFunction m_rotate{m_context, jsObject, "rotate", rotate, 1};
  ObjectFunction m_quadraticCurveTo{m_context, jsObject, "quadraticCurveTo", quadraticCurveTo, 4};
  ObjectFunction m_stroke{m_context, jsObject, "stroke", stroke, 0};
  ObjectFunction m_strokeRect{m_context, jsObject, "strokeRect", strokeRect, 4};
  ObjectFunction m_save{m_context, jsObject, "save", save, 0};
  ObjectFunction m_scale{m_context, jsObject, "scale", scale, 2};
  ObjectFunction m_strokeText{m_context, jsObject, "strokeText", strokeText, 4};
  ObjectFunction m_setTransform{m_context, jsObject, "setTransform", setTransform, 6};
  ObjectFunction m_transform{m_context, jsObject, "transform", transform, 6};
  ObjectFunction m_translate{m_context, jsObject, "translate", translate, 2};
};

class CanvasElement : public Element {
public:
  CanvasElement() = delete;
  explicit CanvasElement(JSContext *context);
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;

  static JSValue getContext(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

private:
  ObjectFunction m_getContext{m_context, m_prototypeObject, "getContext", getContext, 1};
};


class CanvasElementInstance : public ElementInstance {
public:
  CanvasElementInstance() = delete;
  explicit CanvasElementInstance(CanvasElement *element);
private:
  DEFINE_HOST_CLASS_PROPERTY(2, width, height)
};

}

#endif //KRAKENBRIDGE_CANVAS_ELEMENTT_H
