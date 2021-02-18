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
class JSElement;
class ElementInstance;

class JSElementAttributes : public HostObject {
public:
  JSElementAttributes() = delete;
  JSElementAttributes(JSContext *context) : HostObject(context, "NamedNodeMap") {}
  ~JSElementAttributes() override;

  enum class AttributeProperty { kLength };

  static std::vector<JSStringRef> &getAttributePropertyNames();
  static const std::unordered_map<std::string, AttributeProperty> &getAttributePropertyMap();

  JSStringRef getAttribute(std::string &name);
  void setAttribute(std::string &name, JSStringRef value);
  bool hasAttribute(std::string &name);
  void removeAttribute(std::string &name);

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  std::map<std::string, JSStringRef> m_attributes;
  std::vector<JSStringRef> v_attributes;
};

class JSElement : public JSNode {
public:
  DEFINE_OBJECT_PROPERTY(Element, 27, style, nodeName, tagName, attributes, offsetLeft, offsetTop, offsetWidth,
                         offsetHeight, clientWidth, clientHeight, clientTop, clientLeft, scrollTop, scrollLeft,
                         scrollHeight, scrollWidth, getBoundingClientRect, click, scroll, scrollBy, scrollTo, toBlob,
                         getAttribute, setAttribute, hasAttribute, removeAttribute, children)

  enum class ElementTagName {
    kDiv,
    kSpan,
    kAnchor,
    kAnimationPlayer,
    kAudio,
    kVideo,
    kStrong,
    kPre,
    kParagraph,
    kIframe,
    kObject,
    kImage,
    kCanvas,
    kInput,
  };

  static std::unordered_map<JSContext *, JSElement *> instanceMap;
  OBJECT_INSTANCE(JSElement)

  static JSValueRef getBoundingClientRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                          size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef hasAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef setAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef getAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef removeAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef toBlob(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef click(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                          const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef scroll(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static ElementInstance *buildElementInstance(JSContext *context, std::string &tagName);

  JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception) override;

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

protected:
  JSElement() = delete;
  explicit JSElement(JSContext *context);
  ~JSElement();

private:
  friend ElementInstance;
  JSFunctionHolder m_getBoundingClientRect{context, this, "getBoundingClientRect", getBoundingClientRect};
  JSFunctionHolder m_setAttribute{context, this, "setAttribute", setAttribute};
  JSFunctionHolder m_getAttribute{context, this, "getAttribute", getAttribute};
  JSFunctionHolder m_hasAttribute{context, this, "hasAttribute", hasAttribute};
  JSFunctionHolder m_removeAttribute{context, this, "removeAttribute", removeAttribute};
  JSFunctionHolder m_toBlob{context, this, "toBlob", toBlob};
  JSFunctionHolder m_click{context, this, "click", click};
  JSFunctionHolder m_scroll{context, this, "scroll", scroll};
  JSFunctionHolder m_scrollBy{context, this, "scrollBy", scrollBy};
};

class ElementInstance : public JSNode::NodeInstance {
public:
  ElementInstance() = delete;
  explicit ElementInstance(JSElement *element, const char *tagName, bool sendUICommand);
  explicit ElementInstance(JSElement *element, JSStringRef tagName, double targetId);
  ~ElementInstance();

  JSValueRef getStringValueProperty(std::string &name);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  std::string internalGetTextContent() override;
  void internalSetTextContent(JSStringRef content, JSValueRef *exception) override;

  NativeElement *nativeElement{nullptr};

  std::string tagName();

private:
  friend JSElement;
  CSSStyleDeclaration::StyleDeclarationInstance *style{nullptr};
  JSStringHolder m_tagName{context, ""};

  void _notifyNodeRemoved(JSNode::NodeInstance *node) override;
  void _notifyChildRemoved();
  void _notifyNodeInsert(JSNode::NodeInstance *insertNode) override;
  void _notifyChildInsert();
  void _didModifyAttribute(std::string &name, std::string &oldId, std::string &newId);
  void _beforeUpdateId(std::string &oldId, std::string &newId);
  JSHostObjectHolder<JSElementAttributes> m_attributes{context, new JSElementAttributes(context)};
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

enum class ViewModuleProperty {
  offsetTop,
  offsetLeft,
  offsetWidth,
  offsetHeight,
  clientWidth,
  clientHeight,
  clientTop,
  clientLeft,
  scrollTop,
  scrollLeft,
  scrollHeight,
  scrollWidth
};
using GetViewModuleProperty = double (*)(NativeElement *nativeElement, int64_t property);
using SetViewModuleProperty = void (*)(NativeElement *nativeElement, int64_t property, double value);
using GetBoundingClientRect = NativeBoundingClientRect *(*)(NativeElement *nativeElement);
using GetStringValueProperty = NativeString *(*)(NativeElement *nativeElement, NativeString* property);
using Click = void (*)(NativeElement *nativeElement);
using Scroll = void (*)(NativeElement *nativeElement, int32_t x, int32_t y);
using ScrollBy = void (*)(NativeElement *nativeElement, int32_t x, int32_t y);

class BoundingClientRect : public HostObject {
public:
  enum BoundingClientRectProperty { kX, kY, kWidth, kHeight, kLeft, kTop, kRight, kBottom };

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
  explicit NativeElement(NativeNode *nativeNode) : nativeNode(nativeNode){};

  const NativeNode *nativeNode;

  GetViewModuleProperty getViewModuleProperty{nullptr};
  SetViewModuleProperty setViewModuleProperty{nullptr};
  GetBoundingClientRect getBoundingClientRect{nullptr};
  GetStringValueProperty getStringValueProperty{nullptr};
  Click click{nullptr};
  Scroll scroll{nullptr};
  ScrollBy scrollBy{nullptr};
};

using TraverseHandler = std::function<bool(JSNode::NodeInstance *)>;
void traverseNode(JSNode::NodeInstance *node, TraverseHandler handler);

} // namespace kraken::binding::jsc
#endif // KRAKENBRIDGE_ELEMENT_H
