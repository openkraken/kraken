/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "node.h"
#include "style_declaration.h"
#include "bindings/qjs/host_object.h"

namespace kraken::binding::qjs {

class ElementInstance;
class Element;
using ElementCreator = ElementInstance *(*)(Element *element, JSValue &tagName);

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
  ~ElementInstance() override {
      delete m_style;
  }
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
  explicit ElementInstance(Element *element, JSValue &tagName);
  void _notifyNodeRemoved(NodeInstance *node) override;
  void _notifyChildRemoved();
  void _notifyNodeInsert(NodeInstance *insertNode) override;
  void _notifyChildInsert();
  void _didModifyAttribute(std::string &name, JSValue &oldId, JSValue &newId);
  void _beforeUpdateId(JSValue &oldId, JSValue &newId);

  JSAtom m_tagName;
  friend Element;
  StyleDeclarationInstance *m_style{new StyleDeclarationInstance(CSSStyleDeclaration::instance(m_context), this)};
};

class BoundingClientRect : public HostObject<BoundingClientRect> {
public:
  BoundingClientRect() = delete;
  explicit BoundingClientRect(JSContext *context, NativeBoundingClientRect *nativeBoundingClientRect): HostObject<BoundingClientRect>(context, "BoundingClientRect") {

  };

private:
  NativeBoundingClientRect *m_nativeBoundingClientRect{nullptr};
};

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_ELEMENT_H
