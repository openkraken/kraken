/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CANVAS_ELEMENT_H
#define KRAKENBRIDGE_CANVAS_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context.h"

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
  static JSCanvasElement *instance(JSContext *context);

  JSCanvasElement() = delete;
  explicit JSCanvasElement(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class CanvasElementInstance : public ElementInstance {
  public:
    enum class CanvasElementProperty { kWidth, kHeight, kGetContext };
    static std::vector<JSStringRef> &getCanvasElementPropertyNames();
    static const std::unordered_map<std::string, CanvasElementProperty> &getCanvasElementPropertyMap();

    static JSValueRef getContext(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);

    CanvasElementInstance() = delete;
    explicit CanvasElementInstance(JSCanvasElement *jsCanvasElement);
    ~CanvasElementInstance();

    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeCanvasElement *nativeCanvasElement;

  private:
    double _width{300};
    double _height{150};

    JSFunctionHolder m_getContext{context, this, "getContext", getContext};
  };
};

using SetFont = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *font);
using SetFillStyle = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D, NativeString *fillStyle);
using SetStrokeStyle = void (*)(NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D,
                                NativeString *strokeStyle);
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
  static CanvasRenderingContext2D *instance(JSContext *context);

  class CanvasRenderingContext2DInstance : public Instance {
  public:
    enum class CanvasRenderingContext2DProperty {
      kFont,
      kFillStyle,
      kStrokeStyle,
      kFillRect,
      kClearRect,
      kStrokeRect,
      kFillText,
      kStrokeText,
      kSave,
      kReStore,
    };
    static std::vector<JSStringRef> &getCanvasRenderingContext2DPropertyNames();
    static const std::unordered_map<std::string, CanvasRenderingContext2DProperty> &
    getCanvasRenderingContext2DPropertyMap();

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

    CanvasRenderingContext2DInstance() = delete;
    explicit CanvasRenderingContext2DInstance(CanvasRenderingContext2D *canvasRenderContext2D,
                                              NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D);
    ~CanvasRenderingContext2DInstance() override;
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D;

  private:
    JSStringHolder m_font{context, ""};
    JSStringHolder m_fillStyle{context, ""};
    JSStringHolder m_strokeStyle{context, ""};

    JSFunctionHolder m_fillRect{context, this, "fillRect", fillRect};
    JSFunctionHolder m_clearRect{context, this, "clearRect", clearRect};
    JSFunctionHolder m_strokeRect{context, this, "strokeRect", strokeRect};
    JSFunctionHolder m_fillText{context, this, "fillText", fillText};
    JSFunctionHolder m_strokeText{context, this, "strokeText", strokeText};
    JSFunctionHolder m_save{context, this, "save", save};
    JSFunctionHolder m_restore{context, this, "restore", restore};
  };
protected:
  CanvasRenderingContext2D() = delete;
  explicit CanvasRenderingContext2D(JSContext *context);
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_CANVAS_ELEMENT_H
