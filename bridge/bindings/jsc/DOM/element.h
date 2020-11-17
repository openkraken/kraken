/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "bindings/jsc/host_object.h"
#include "include/kraken_bridge.h"
#include "node.h"
#include "style_declaration.h"
#include <vector>

namespace kraken::binding::jsc {

void bindElement(std::unique_ptr<JSContext> &context);

struct NativeElement;

class JSElement : public JSNode {
public:
  enum class ElementProperty {
    kStyle,
    kNodeName,
    kOffsetLeft,
    kOffsetTop,
    kOffsetWidth,
    kOffsetHeight,
    kClientWidth,
    kClientHeight,
    kClientTop,
    kClientLeft,
    kScrollTop,
    kScrollLeft,
    kScrollHeight,
    kScrollWidth,
    kGetBoundingClientRect,
    kClick,
    kScroll,
    kScrollBy,
    kToBlob,
    kGetAttribute,
    kSetAttribute,
    kChildren
  };

  static JSElement *instance(JSContext *context);

  JSElement() = delete;
  explicit JSElement(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class ElementInstance : public NodeInstance {
  public:
    static std::array<JSStringRef, 1> &getElementPropertyNames();
    static const std::unordered_map<std::string, ElementProperty> &getPropertyMap();

    static JSValueRef getBoundingClientRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                            size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

    static JSValueRef setAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);
    static JSValueRef getAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);
    static JSValueRef toBlob(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
    static JSValueRef click(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception);
    static JSValueRef scroll(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
    static JSValueRef scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef arguments[], JSValueRef *exception);

    ElementInstance() = delete;
    explicit ElementInstance(JSElement *element, JSValueRef tagNameValue, double targetId, JSValueRef *exception);
    explicit ElementInstance(JSElement *element, const char *tagName);
    ~ElementInstance();
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    JSStringRef internalTextContent() override;

    NativeElement *nativeElement {nullptr};
  private:
    CSSStyleDeclaration::StyleDeclarationInstance *style{nullptr};
    JSStringRef tagNameStringRef_ {nullptr};
    JSObjectRef _getBoundingClientRect{nullptr};
    JSObjectRef _setAttribute{nullptr};
    JSObjectRef _getAttribute{nullptr};
    JSObjectRef _toBlob{nullptr};
    JSObjectRef _click{nullptr};
    JSObjectRef _scroll{nullptr};
    JSObjectRef _scrollBy{nullptr};
    std::unordered_map<std::string, JSStringRef> attributes;
  };
};

struct NativeBoundingClientRect {
  double x;
  double y;
  double width;
  double height;
  double top;
  double right;
  double bottom;
  double left;
};

using GetOffsetTop = double (*)(NativeElement *nativeElement);
using GetOffsetLeft = double (*)(NativeElement *nativeElement);
using GetOffsetWidth = double (*)(NativeElement *nativeElement);
using GetOffsetHeight = double (*)(NativeElement *nativeElement);
using GetClientWidth = double (*)(NativeElement *nativeElement);
using GetClientHeight = double (*)(NativeElement *nativeElement);
using GetClientTop = double (*)(NativeElement *nativeElement);
using GetClientLeft = double (*)(NativeElement *nativeElement);
using GetScrollTop = double (*)(NativeElement *nativeElement);
using GetScrollLeft = double (*)(NativeElement *nativeElement);
using GetScrollHeight = double (*)(NativeElement *nativeElement);
using GetScrollWidth = double (*)(NativeElement *nativeElement);
using GetBoundingClientRect = NativeBoundingClientRect *(*)(NativeElement *nativeElement);
using Click = void (*)(NativeElement *nativeElement);
using Scroll = void (*)(NativeElement *nativeElement, int32_t x, int32_t y);
using ScrollBy = void (*)(NativeElement *nativeElement, int32_t x, int32_t y);

class BoundingClientRect : public HostObject {
public:
  enum BoundingClientRectProperty {
    kX,
    kY,
    kWidth,
    kHeight,
    kLeft,
    kTop,
    kRight,
    kBottom
  };

  static std::array<JSStringRef, 8> &getBoundingClientRectPropertyNames();
  static const std::unordered_map<std::string, BoundingClientRectProperty> &getPropertyMap();

  BoundingClientRect() = delete;
  ~BoundingClientRect() override;
  BoundingClientRect(JSContext *context, NativeBoundingClientRect *boundingClientRect);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  NativeBoundingClientRect *nativeBoundingClientRect;
};

// An struct represent Element object from dart side.
struct NativeElement {
  NativeElement() = delete;
  explicit NativeElement(NativeNode *nativeNode): nativeNode(nativeNode) {};

  const NativeNode *nativeNode;

  GetOffsetTop getOffsetTop{nullptr};
  GetOffsetLeft getOffsetLeft{nullptr};
  GetOffsetWidth getOffsetWidth{nullptr};
  GetOffsetHeight getOffsetHeight{nullptr};
  GetClientWidth getClientWidth{nullptr};
  GetClientHeight getClientHeight{nullptr};
  GetClientTop getClientTop{nullptr};
  GetClientLeft getClientLeft{nullptr};
  GetScrollTop getScrollTop{nullptr};
  GetScrollLeft getScrollLeft{nullptr};
  GetScrollHeight getScrollHeight{nullptr};
  GetScrollWidth getScrollWidth{nullptr};
  GetBoundingClientRect getBoundingClientRect{nullptr};
  Click click{nullptr};
  Scroll scroll{nullptr};
  ScrollBy scrollBy{nullptr};
};

} // namespace kraken::binding::jsc
#endif // KRAKENBRIDGE_ELEMENT_H
