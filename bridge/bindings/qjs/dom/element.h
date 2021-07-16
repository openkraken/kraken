/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "node.h"
#include "style_declaration.h"
#include "bindings/qjs/host_object.h"
#include <unordered_map>

namespace kraken::binding::qjs {

void bindElement(std::unique_ptr<JSContext> &context);

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

class ElementAttributes : public HostObject {
public:
  ElementAttributes() = delete;
  explicit ElementAttributes(JSContext *context) : HostObject(context, "ElementAttributes") {}
  ~ElementAttributes() {
    KRAKEN_LOG(VERBOSE) << "delete attributes";
  };

  JSValue getAttribute(std::string &name);
  JSValue setAttribute(std::string &name, JSValue value);
  bool hasAttribute(std::string &name);
  void removeAttribute(std::string &name);

private:
  std::unordered_map<std::string, JSValue> m_attributes;
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

  DEFINE_HOST_CLASS_PROPERTY(15, nodeName, tagName, offsetLeft, offsetTop, offsetWidth, offsetHeight,
                             clientWidth, clientHeight, clientTop, clientLeft, scrollTop, scrollLeft, scrollHeight,
                             scrollWidth, children);
private:
  friend ElementInstance;
};

class ElementInstance : public NodeInstance {
public:
  ElementInstance() = delete;
  ~ElementInstance() override {
    JS_FreeAtom(m_ctx, m_tagName);
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
  explicit ElementInstance(Element *element, JSValue &tagName, bool shouldAddUICommand);
  void _notifyNodeRemoved(NodeInstance *node) override;
  void _notifyChildRemoved();
  void _notifyNodeInsert(NodeInstance *insertNode) override;
  void _notifyChildInsert();
  void _didModifyAttribute(std::string &name, JSValue &oldId, JSValue &newId);
  void _beforeUpdateId(JSValue &oldId, JSValue &newId);

  JSAtom m_tagName;
  friend Element;
  StyleDeclarationInstance *m_style{nullptr};
  ElementAttributes *m_attributes{nullptr};
};

class BoundingClientRect : public HostObject {
public:
  BoundingClientRect() = delete;
  explicit BoundingClientRect(JSContext *context, NativeBoundingClientRect *nativeBoundingClientRect): HostObject(context, "BoundingClientRect") {

  };

private:
  NativeBoundingClientRect *m_nativeBoundingClientRect{nullptr};
};

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_ELEMENT_H
