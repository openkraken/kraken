/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "node.h"

namespace kraken::binding::qjs {

// class KRAKEN_EXPORT JSElement : public JSNode {
// public:
//   DEFINE_OBJECT_PROPERTY(Element, 17, style, attributes, nodeName, tagName, offsetLeft, offsetTop, offsetWidth,
//   offsetHeight, clientWidth, clientHeight, clientTop, clientLeft, scrollTop, scrollLeft,
//   scrollHeight, scrollWidth, children);
//
//   DEFINE_PROTOTYPE_OBJECT_PROPERTY(Element, 10, getBoundingClientRect, getAttribute, setAttribute, hasAttribute,
//   removeAttribute, toBlob, click, scroll, scrollBy, scrollTo);
//
//   static std::unordered_map<JSContext *, JSElement *> instanceMap;
//   static std::unordered_map<std::string, ElementCreator> elementCreatorMap;
//   OBJECT_INSTANCE(JSElement)
//
//   static ElementInstance *buildElementInstance(JSContext *context, std::string &tagName);
//
//   JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception) override;
//
//   JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
//                                   const JSValueRef *arguments, JSValueRef *exception) override;
//
//   static void defineElement(std::string tagName, ElementCreator creator);
//
// protected:
//   JSElement() = delete;
//   explicit JSElement(JSContext *context);
//   ~JSElement();
//
// private:
//   friend ElementInstance;
//
//   static JSValueRef getBoundingClientRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
//                                           size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
//
//   static JSValueRef hasAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t
//   argumentCount,
//                                  const JSValueRef arguments[], JSValueRef *exception);
//   static JSValueRef setAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t
//   argumentCount,
//                                  const JSValueRef arguments[], JSValueRef *exception);
//   static JSValueRef getAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t
//   argumentCount,
//                                  const JSValueRef arguments[], JSValueRef *exception);
//   static JSValueRef removeAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
//                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
//   static JSValueRef toBlob(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                            const JSValueRef arguments[], JSValueRef *exception);
//   static JSValueRef click(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                           const JSValueRef arguments[], JSValueRef *exception);
//   static JSValueRef scroll(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                            const JSValueRef arguments[], JSValueRef *exception);
//   static JSValueRef scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                              const JSValueRef arguments[], JSValueRef *exception);
//   JSFunctionHolder m_getBoundingClientRect{context, prototypeObject, this, "getBoundingClientRect",
//                                            getBoundingClientRect};
//   JSFunctionHolder m_setAttribute{context, prototypeObject, this, "setAttribute", setAttribute};
//   JSFunctionHolder m_getAttribute{context, prototypeObject, this, "getAttribute", getAttribute};
//   JSFunctionHolder m_hasAttribute{context, prototypeObject, this, "hasAttribute", hasAttribute};
//   JSFunctionHolder m_removeAttribute{context, prototypeObject, this, "removeAttribute", removeAttribute};
//   JSFunctionHolder m_toBlob{context, prototypeObject, this, "toBlob", toBlob};
//   JSFunctionHolder m_click{context, prototypeObject, this, "click", click};
//   JSFunctionHolder m_scroll{context, prototypeObject, this, "scroll", scroll};
//   JSFunctionHolder m_scrollTo{context, prototypeObject, this, "scrollTo", scroll};
//   JSFunctionHolder m_scrollBy{context, prototypeObject, this, "scrollBy", scrollBy};
// };
//
// class KRAKEN_EXPORT ElementInstance : public NodeInstance {
// public:
//   ElementInstance() = delete;
//   explicit ElementInstance(JSElement *element, const char *tagName, bool shouldAddUICommand);
//   explicit ElementInstance(JSElement *element, JSStringRef tagName, double targetId);
//   ~ElementInstance();
//
//   JSValueRef getStringValueProperty(std::string &name);
//   JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
//   bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
//   void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
//   std::string internalGetTextContent() override;
//   void internalSetTextContent(JSStringRef content, JSValueRef *exception) override;
//   JSHostObjectHolder<JSElementAttributes>& getAttributes();
//   JSHostClassHolder& getStyle();
//   void setStyle(JSHostClassHolder& style);
//   void setAttributes(JSHostObjectHolder<JSElementAttributes>& attributes);
//
//   NativeElement *nativeElement{nullptr};
//
//   std::string tagName();
//
//   std::string getRegisteredTagName();
//
// private:
//   friend JSElement;
//   JSStringHolder m_tagName{context, ""};
//
//   KRAKEN_EXPORT void _notifyNodeRemoved(NodeInstance *node) override;
//   void _notifyChildRemoved();
//   KRAKEN_EXPORT void _notifyNodeInsert(NodeInstance *insertNode) override;
//   void _notifyChildInsert();
//   void _didModifyAttribute(std::string &name, JSValueRef oldId, JSValueRef newId);
//   void _beforeUpdateId(JSValueRef oldId, JSValueRef newId);
//   JSHostObjectHolder<JSElementAttributes> m_attributes{context, object, "attributes", new
//   JSElementAttributes(context)}; JSHostClassHolder m_style{context, object, "style",
//                             new StyleDeclarationInstance(CSSStyleDeclaration::instance(context), this)};
// };

class ElementInstance;
class Element;
using ElementCreator = ElementInstance *(*)(Element *element, JSValue &tagName, DocumentInstance *document);

class Element : public Node {
public:
  Element() = delete;
  explicit Element(JSContext *context): Node(context, "Element") {}

  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;

  static JSValue getBoundingClientRect(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue hasAttribute(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue setAttribute(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue getAttribute(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue removeAttribute(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue toBlob(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue click(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue scroll(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue scrollBy(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

  static void defineElement(const std::string& tagName, ElementCreator creator);

  static std::unordered_map<std::string, ElementCreator> elementCreatorMap;

  OBJECT_INSTANCE(Element);

  DEFINE_HOST_CLASS_PROPERTY(17, style, attributes, nodeName, tagName, offsetLeft, offsetTop, offsetWidth, offsetHeight,
                             clientWidth, clientHeight, clientTop, clientLeft, scrollTop, scrollLeft, scrollHeight,
                             scrollWidth, children);
private:
  friend ElementInstance;
};

class ElementInstance : public NodeInstance {
public:
  ElementInstance() = delete;
  JSValue getStringValueProperty(std::string &name);
  std::string internalGetTextContent() override;
  void internalSetTextContent(JSValue content) override;
//  JSHostObjectHolder<JSElementAttributes> &getAttributes();
//  JSHostClassHolder &getStyle();
//  void setStyle(JSHostClassHolder &style);
//  void setAttributes(JSHostObjectHolder<JSElementAttributes> &attributes);

  std::string tagName();
  std::string getRegisteredTagName();

private:
  explicit ElementInstance(Element *element, JSValue &tagName, DocumentInstance *document);
  void _notifyNodeRemoved(NodeInstance *node) override;
  void _notifyChildRemoved();
  void _notifyNodeInsert(NodeInstance *insertNode) override;
  void _notifyChildInsert();
  void _didModifyAttribute(std::string &name, JSValue &oldId, JSValue &newId);
  void _beforeUpdateId(JSValue &oldId, JSValue &newId);

  std::string m_tagName;
  friend Element;
};

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_ELEMENT_H
