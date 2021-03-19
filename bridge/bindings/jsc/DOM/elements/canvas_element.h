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
    DEFINE_OBJECT_PROPERTY(CanvasElement, 2, width, height)
    DEFINE_PROTOTYPE_OBJECT_PROPERTY(CanvasElement, 1, getContext)

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

using SetFont = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *font);
using SetFillStyle = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *fillStyle);
using SetStrokeStyle = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D,
                                NativeString *strokeStyle);
using Translate = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y);
using FillRect = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y,
                          double width, double height);
using ClearRect = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y,
                           double width, double height);
using StrokeRect = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, double x, double y,
                            double width, double height);
using FillText = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *text, double x,
                          double y, double maxWidth);
using StrokeText = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *text,
                            double x, double y, double maxWidth);
using Save = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);
using Restore = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);

struct NativeCanvasRenderingContext2D {
  SetFont setFont{nullptr};
  SetFillStyle setFillStyle{nullptr};
  SetStrokeStyle setStrokeStyle{nullptr};
  Translate translate{nullptr};
  FillRect fillRect{nullptr};
  ClearRect clearRect{nullptr};
  StrokeRect strokeRect{nullptr};
  FillText fillText{nullptr};
  StrokeText strokeText{nullptr};
  Save save{nullptr};
  Restore restore{nullptr};
};

class CanvasRenderingContext2D : public HostClass {
public:
  static std::unordered_map<JSContext *, CanvasRenderingContext2D *> instanceMap;
  OBJECT_INSTANCE(CanvasRenderingContext2D)

  static JSValueRef translate(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef fillRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef clearRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef strokeRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef fillText(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef strokeText(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef save(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef restore(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception);

  class CanvasRenderingContext2DInstance : public Instance {
  public:
    DEFINE_OBJECT_PROPERTY(CanvasRenderingContext2D, 3, font, fillStyle, strokeStyle)
    DEFINE_PROTOTYPE_OBJECT_PROPERTY(CanvasRenderingContext2D, 7, fillRect, clearRect, strokeRect,
                                  fillText, strokeText, save, restore)

    CanvasRenderingContext2DInstance() = delete;
    explicit CanvasRenderingContext2DInstance(CanvasRenderingContext2D *canvasRenderContext2D,
                                              NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);
    ~CanvasRenderingContext2DInstance() override;
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D;

  private:
    JSStringHolder m_font{context, ""};
    JSStringHolder m_fillStyle{context, ""};
    JSStringHolder m_strokeStyle{context, ""};
  };

protected:
  CanvasRenderingContext2D() = delete;
  explicit CanvasRenderingContext2D(JSContext *context);

  JSFunctionHolder m_fillRect{context, prototypeObject, this, "translate", translate};
  JSFunctionHolder m_fillRect{context, prototypeObject, this, "fillRect", fillRect};
  JSFunctionHolder m_clearRect{context, prototypeObject, this, "clearRect", clearRect};
  JSFunctionHolder m_strokeRect{context, prototypeObject, this, "strokeRect", strokeRect};
  JSFunctionHolder m_fillText{context, prototypeObject, this, "fillText", fillText};
  JSFunctionHolder m_strokeText{context, prototypeObject, this, "strokeText", strokeText};
  JSFunctionHolder m_save{context, prototypeObject, this, "save", save};
  JSFunctionHolder m_restore{context, prototypeObject, this, "restore", restore};
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_CANVAS_ELEMENT_H
