/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include <unordered_map>
#include "bindings/qjs/host_object.h"
#include "node.h"
#include "style_declaration.h"

namespace kraken::binding::qjs {

void bindElement(std::unique_ptr<JSContext>& context);

class ElementInstance;

class Element;

using ElementCreator = ElementInstance* (*)(Element* element, std::string tagName);

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

class SpaceSplitString {
 public:
  SpaceSplitString() = default;
  explicit SpaceSplitString(std::string string) { set(string); }

  void set(std::string& string);
  bool contains(std::string& string);
  bool containsAll(std::string s);

 private:
  static std::string m_delimiter;
  std::vector<std::string> m_szData;
};

class ElementAttributes : public HostObject {
 public:
  ElementAttributes() = delete;
  explicit ElementAttributes(JSContext* context) : HostObject(context, "ElementAttributes") {}
  ~ElementAttributes();

  JSAtom getAttribute(const std::string& name);
  JSValue setAttribute(const std::string& name, JSAtom value);
  bool hasAttribute(std::string& name);
  void removeAttribute(std::string& name);
  void copyWith(ElementAttributes* attributes);
  std::shared_ptr<SpaceSplitString> className();
  std::string toString();

 private:
  std::unordered_map<std::string, JSAtom> m_attributes;
  std::shared_ptr<SpaceSplitString> m_className{std::make_shared<SpaceSplitString>("")};
};

bool isJavaScriptExtensionElementInstance(JSContext* context, JSValue instance);

class Element : public Node {
 public:
  static JSClassID kElementClassId;
  Element() = delete;
  explicit Element(JSContext* context);

  static JSClassID classId();

  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  static JSValue getBoundingClientRect(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue hasAttribute(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue setAttribute(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getAttribute(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue removeAttribute(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue toBlob(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue click(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue scroll(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue scrollBy(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  OBJECT_INSTANCE(Element);

 private:
  DEFINE_PROTOTYPE_READONLY_PROPERTY(nodeName);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(tagName);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(offsetLeft);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(offsetTop);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(offsetWidth);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(offsetHeight);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(clientWidth);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(clientHeight);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(clientTop);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(clientLeft);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(scrollHeight);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(scrollWidth);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(firstElementChild);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(lastElementChild);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(children);

  DEFINE_PROTOTYPE_PROPERTY(className);
  DEFINE_PROTOTYPE_PROPERTY(innerHTML);
  DEFINE_PROTOTYPE_PROPERTY(outerHTML);
  DEFINE_PROTOTYPE_PROPERTY(scrollTop);
  DEFINE_PROTOTYPE_PROPERTY(scrollLeft);

  DEFINE_PROTOTYPE_FUNCTION(getBoundingClientRect, 0);
  DEFINE_PROTOTYPE_FUNCTION(hasAttribute, 1);
  DEFINE_PROTOTYPE_FUNCTION(setAttribute, 2);
  DEFINE_PROTOTYPE_FUNCTION(getAttribute, 2);
  DEFINE_PROTOTYPE_FUNCTION(removeAttribute, 1);
  DEFINE_PROTOTYPE_FUNCTION(toBlob, 0);
  DEFINE_PROTOTYPE_FUNCTION(click, 2);
  DEFINE_PROTOTYPE_FUNCTION(scroll, 2);
  // ScrollTo is same as scroll which reuse scroll functions. Macro expand is not support here.
  ObjectFunction m_scrollTo{m_context, m_prototypeObject, "scrollTo", scroll, 2};
  DEFINE_PROTOTYPE_FUNCTION(scrollBy, 2);
  friend ElementInstance;
};

struct PersistElement {
  ElementInstance* element;
  list_head link;
};

class ElementInstance : public NodeInstance {
 public:
  ElementInstance() = delete;
  ~ElementInstance();
  JSValue internalGetTextContent() override;
  void internalSetTextContent(JSValue content) override;

  std::shared_ptr<SpaceSplitString> classNames();
  std::string tagName();
  std::string getRegisteredTagName();
  std::string outerHTML();
  std::string innerHTML();
  StyleDeclarationInstance* style();
  ElementAttributes* attributes();

  static inline JSClassID classID();

 protected:
  explicit ElementInstance(Element* element, std::string tagName, bool shouldAddUICommand);

 private:
  void _notifyNodeRemoved(NodeInstance* node) override;
  void _notifyChildRemoved();
  void _notifyNodeInsert(NodeInstance* insertNode) override;
  void _notifyChildInsert();
  void _didModifyAttribute(std::string& name, JSAtom oldId, JSAtom newId);
  void _beforeUpdateId(JSAtom oldId, JSAtom newId);

  std::string m_tagName;
  friend Element;
  friend NodeInstance;
  friend Node;
  friend DocumentInstance;
  StyleDeclarationInstance* m_style{nullptr};
  ElementAttributes* m_attributes{nullptr};

  static JSClassExoticMethods exoticMethods;
};

class BoundingClientRect : public HostObject {
 public:
  BoundingClientRect() = delete;
  explicit BoundingClientRect(JSContext* context, NativeBoundingClientRect* nativeBoundingClientRect)
      : HostObject(context, "BoundingClientRect"), m_nativeBoundingClientRect(nativeBoundingClientRect){};

 private:
  DEFINE_READONLY_PROPERTY(x);
  DEFINE_READONLY_PROPERTY(y);
  DEFINE_READONLY_PROPERTY(width);
  DEFINE_READONLY_PROPERTY(height);
  DEFINE_READONLY_PROPERTY(top);
  DEFINE_READONLY_PROPERTY(right);
  DEFINE_READONLY_PROPERTY(bottom);
  DEFINE_READONLY_PROPERTY(left);

  NativeBoundingClientRect* m_nativeBoundingClientRect{nullptr};
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_ELEMENT_H
