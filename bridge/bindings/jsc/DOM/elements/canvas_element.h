/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CANVAS_ELEMENT_H
#define KRAKENBRIDGE_CANVAS_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

struct NativeCanvasRenderingContext2D;
struct NativeCanvasElement;

using GetContext = NativeCanvasRenderingContext2D *(*)(NativeCanvasElement *nativeCanvasElement,
                                                       NativeString *contextId);

struct NativeCanvasElement {
  NativeCanvasElement() = delete;
  NativeCanvasElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;

  GetContext getContext{nullptr};
};

class JSCanvasElement : public JSElement {
public:
  static std::unordered_map<JSContext *, JSCanvasElement *> instanceMap;
  OBJECT_INSTANCE(JSCanvasElement)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class CanvasElementInstance : public ElementInstance {
  public:
    DEFINE_OBJECT_PROPERTY(CanvasElement, 2, width, height);
    DEFINE_PROTOTYPE_OBJECT_PROPERTY(CanvasElement, 1, getContext);

    CanvasElementInstance() = delete;
    explicit CanvasElementInstance(JSCanvasElement *jsCanvasElement);
    ~CanvasElementInstance();

    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeCanvasElement *nativeCanvasElement;

  private:
    double _width{300};
    double _height{150};
  };

private:
  JSCanvasElement() = delete;
  ~JSCanvasElement();
  explicit JSCanvasElement(JSContext *context);

  static JSValueRef getContext(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef arguments[], JSValueRef *exception);
  JSFunctionHolder m_getContext{context, prototypeObject, this, "getContext", getContext};
};


using SetProperty = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *value);
using Arc = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y,
                    double radius, double startAngle, double endAngle, double counterclockwise);
using ArcTo = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x1, double y1,
                      double x2, double y2, double radius);
using BeginPath = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);
using BezierCurveTo = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x1, double y1,
                              double x2, double y2, double x, double y);
using ClearRect = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y,
                           double width, double height);
using Clip = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *fillRule);
using ClosePath = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);
using DrawImage = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeImageElement *nativeImage, double dx, double dy);
using Ellipse = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y,
                        double radiusX, double radiusY, double rotation, double startAngle, double endAngle, double counterclockwise);
using Fill = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *fillRule);
using FillRect = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y,
                          double width, double height);
using FillText = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *text, double x,
                          double y, double maxWidth);
using LineTo = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y);
using MoveTo = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y);
using QuadraticCurveTo = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double cpx, double cpy,
                           double x, double y);
using Rect = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y,
                           double width, double height);
using Rotate = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double angle);
using Restore = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);
using ResetTransform = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderinContext2D);
using Save = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);
using Scale = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y);
using Stroke = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);
using StrokeRect = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y,
                            double width, double height);
using StrokeText = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *text,
                            double x, double y, double maxWidth);
using SetTransform = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double a, double b, double c, double d, double e, double f);
using Transform = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double a, double b, double c, double d, double e, double f);
using Translate = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y);

// Function pointer's order must be as same as the NativeCanvasRenderingContext2D class of dart side.
struct NativeCanvasRenderingContext2D {
  SetProperty setDirection{nullptr};
  SetProperty setFont{nullptr};
  SetProperty setFillStyle{nullptr};
  SetProperty setStrokeStyle{nullptr};
  SetProperty setLineCap{nullptr};
  SetProperty setLineDashOffset{nullptr};
  SetProperty setLineJoin{nullptr};
  SetProperty setLineWidth{nullptr};
  SetProperty setMiterLimit{nullptr};
  SetProperty setTextAlign{nullptr};
  SetProperty setTextBaseline{nullptr};
  Arc arc{nullptr};
  ArcTo arcTo{nullptr};
  BeginPath beginPath{nullptr};
  BezierCurveTo bezierCurveTo{nullptr};
  ClearRect clearRect{nullptr};
  Clip clip{nullptr};
  ClosePath closePath{nullptr};
  DrawImage drawImage{nullptr};
  Ellipse ellipse{nullptr};
  Fill fill{nullptr};
  FillRect fillRect{nullptr};
  FillText fillText{nullptr};
  LineTo lineTo{nullptr};
  MoveTo moveTo{nullptr};
  QuadraticCurveTo quadraticCurveTo{nullptr};
  Rect rect{nullptr};
  Restore restore{nullptr};
  Rotate rotate{nullptr};
  ResetTransform resetTransform{nullptr};
  Save save{nullptr};
  Scale scale{nullptr};
  Stroke stroke{nullptr};
  StrokeRect strokeRect{nullptr};
  StrokeText strokeText{nullptr};
  SetTransform setTransform{nullptr};
  Transform transform{nullptr};
  Translate translate{nullptr};
};

class CanvasRenderingContext2D : public HostClass {
public:
  static std::unordered_map<JSContext *, CanvasRenderingContext2D *> instanceMap;
  OBJECT_INSTANCE(CanvasRenderingContext2D)
  // 2D
  static JSValueRef arc(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef arcTo(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef beginPath(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef bezierCurveTo(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef closePath(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef clip(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef clearRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef drawImage(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef ellipse(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef fill(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef fillText(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef fillRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef lineTo(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef moveTo(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef quadraticCurveTo(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef restore(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef rotate(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef rect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef resetTransform(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef stroke(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef strokeText(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef strokeRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef save(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef scale(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef setTransform(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef transform(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef translate(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);

  class CanvasRenderingContext2DInstance : public Instance {
  public:
    DEFINE_OBJECT_PROPERTY(CanvasRenderingContext2D, 11,
                          direction, font, fillStyle, strokeStyle, lineCap,
                          lineDashOffset, lineJoin, lineWidth, miterLimit, textAlign,
                          textBaseline);
    DEFINE_PROTOTYPE_OBJECT_PROPERTY(CanvasRenderingContext2D, 27,
                                    arc, arcTo, beginPath, bezierCurveTo, clearRect,
                                    closePath, clip, drawImage, ellipse, fill, fillRect,
                                    fillText, lineTo, moveTo, rect, restore,
                                    resetTransform, rotate, quadraticCurveTo, stroke, strokeRect,
                                    save, scale, strokeText, setTransform, transform,
                                    translate);

    CanvasRenderingContext2DInstance() = delete;
    explicit CanvasRenderingContext2DInstance(CanvasRenderingContext2D *canvasRenderContext2D,
                                              NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);
    ~CanvasRenderingContext2DInstance() override;
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D;

  private:
    JSStringHolder m_direction{context, ""};
    JSStringHolder m_font{context, ""};
    JSStringHolder m_fillStyle{context, ""};
    JSStringHolder m_lineCap{context, ""};
    JSStringHolder m_lineDashOffset{context, ""};
    JSStringHolder m_lineJoin{context, ""};
    JSStringHolder m_lineWidth{context, ""};
    JSStringHolder m_miterLimit{context, ""};
    JSStringHolder m_strokeStyle{context, ""};
    JSStringHolder m_textAlign{context, ""};
    JSStringHolder m_textBaseline{context, ""};
  };

protected:
  CanvasRenderingContext2D() = delete;
  explicit CanvasRenderingContext2D(JSContext *context);

  JSFunctionHolder m_arc{context, prototypeObject, this, "arc", arc};
  JSFunctionHolder m_arcTo{context, prototypeObject, this, "arcTo", arcTo};
  JSFunctionHolder m_beginPath{context, prototypeObject, this, "beginPath", beginPath};
  JSFunctionHolder m_bezierCurveTo{context, prototypeObject, this, "bezierCurveTo", bezierCurveTo};
  JSFunctionHolder m_closePath{context, prototypeObject, this, "closePath", closePath};
  JSFunctionHolder m_clearRect{context, prototypeObject, this, "clearRect", clearRect};
  JSFunctionHolder m_clip{context, prototypeObject, this, "clip", clip};
  JSFunctionHolder m_drawImage{context, prototypeObject, this, "drawImage", drawImage};
  JSFunctionHolder m_ellipse{context, prototypeObject, this, "ellipse", ellipse};
  JSFunctionHolder m_fill{context, prototypeObject, this, "fill", fill};
  JSFunctionHolder m_fillText{context, prototypeObject, this, "fillText", fillText};
  JSFunctionHolder m_fillRect{context, prototypeObject, this, "fillRect", fillRect};
  JSFunctionHolder m_lineTo{context, prototypeObject, this, "lineTo", lineTo};
  JSFunctionHolder m_moveTo{context, prototypeObject, this, "moveTo", moveTo};
  JSFunctionHolder m_quadraticCurveTo{context, prototypeObject, this, "quadraticCurveTo", quadraticCurveTo};
  JSFunctionHolder m_rect{context, prototypeObject, this, "rect", rect};
  JSFunctionHolder m_rotate{context, prototypeObject, this, "rotate", rotate};
  JSFunctionHolder m_restore{context, prototypeObject, this, "restore", restore};
  JSFunctionHolder m_resetTransform{context, prototypeObject, this, "resetTransform", resetTransform};
  JSFunctionHolder m_save{context, prototypeObject, this, "save", save};
  JSFunctionHolder m_scale{context, prototypeObject, this, "scale", scale};
  JSFunctionHolder m_stroke{context, prototypeObject, this, "stroke", stroke};
  JSFunctionHolder m_strokeRect{context, prototypeObject, this, "strokeRect", strokeRect};
  JSFunctionHolder m_strokeText{context, prototypeObject, this, "strokeText", strokeText};
  JSFunctionHolder m_setTransform{context, prototypeObject, this, "setTransform", setTransform};
  JSFunctionHolder m_transform{context, prototypeObject, this, "transform", transform};
  JSFunctionHolder m_translate{context, prototypeObject, this, "translate", translate};
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_CANVAS_ELEMENT_H
