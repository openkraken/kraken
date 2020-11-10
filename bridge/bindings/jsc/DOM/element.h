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

class JSElement : public JSNode {
public:
  static JSElement *instance(JSContext *context);

  JSElement() = delete;
  explicit JSElement(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class ElementInstance : public NodeInstance {
  public:
    static std::array<JSStringRef, 1> &getElementPropertyNames();

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
    JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    JSStringRef internalTextContent() override;

  private:
    CSSStyleDeclaration::StyleDeclarationInstance *style{nullptr};
    JSStringRef tagNameStringRef_;
    JSObjectRef _getBoundingClientRect{nullptr};
    JSObjectRef _setAttribute;
    JSObjectRef _getAttribute;
    JSObjectRef _toBlob;
    JSObjectRef _click;
    JSObjectRef _scroll;
    JSObjectRef _scrollBy;
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

using GetOffsetTop = double (*)(int32_t contextId, int64_t targetId);
using GetOffsetLeft = double (*)(int32_t contextId, int64_t targetId);
using GetOffsetWidth = double (*)(int32_t contextId, int64_t targetId);
using GetOffsetHeight = double (*)(int32_t contextId, int64_t targetId);
using GetClientWidth = double (*)(int32_t contextId, int64_t targetId);
using GetClientHeight = double (*)(int32_t contextId, int64_t targetId);
using GetClientTop = double (*)(int32_t contextId, int64_t targetId);
using GetClientLeft = double (*)(int32_t contextId, int64_t targetId);
using GetScrollTop = double (*)(int32_t contextId, int64_t targetId);
using GetScrollLeft = double (*)(int32_t contextId, int64_t targetId);
using GetScrollHeight = double (*)(int32_t contextId, int64_t targetId);
using GetScrollWidth = double (*)(int32_t contextId, int64_t targetId);
using GetBoundingClientRect = NativeBoundingClientRect *(*)(int32_t contextId, int64_t targetId);
using Click = void (*)(int32_t contextId, int64_t targetId);
using Scroll = void (*)(int32_t contextId, int64_t targetId, int32_t x, int32_t y);
using ScrollBy = void (*)(int32_t contextId, int64_t targetId, int32_t x, int32_t y);

class BoundingClientRect : public HostObject {
public:
  static std::array<JSStringRef, 8> &getBoundingClientRectPropertyNames();

  BoundingClientRect() = delete;
  ~BoundingClientRect() override;
  BoundingClientRect(JSContext *context, NativeBoundingClientRect *boundingClientRect);
  JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  NativeBoundingClientRect *nativeBoundingClientRect;
};

// An struct represent Element object from dart side.
struct NativeElement : public NativeNode {
  NativeElement() = delete;
  NativeElement(JSElement::ElementInstance *instance) : NativeNode(instance){};

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
