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

  static void defineElement(const std::string& tagName, Element* constructor);
  static JSValue getConstructor(JSContext* context, const std::string& tagName);

  static std::unordered_map<std::string, Element*> elementConstructorMap;

  OBJECT_INSTANCE(Element);

#if IS_TEST
  static JSValue profile(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
#endif

 private:
  ObjectFunction m_getBoundingClientRect{m_context, m_prototypeObject, "getBoundingClientRect", getBoundingClientRect, 0};
  ObjectFunction m_hasAttribute{m_context, m_prototypeObject, "hasAttribute", hasAttribute, 1};
  ObjectFunction m_setAttribute{m_context, m_prototypeObject, "setAttribute", setAttribute, 2};
  ObjectFunction m_getAttribute{m_context, m_prototypeObject, "getAttribute", getAttribute, 2};
  ObjectFunction m_removeAttribute{m_context, m_prototypeObject, "removeAttribute", removeAttribute, 1};
  ObjectFunction m_toBlob{m_context, m_prototypeObject, "toBlob", toBlob, 0};
  ObjectFunction m_click{m_context, m_prototypeObject, "click", click, 0};
  ObjectFunction m_scroll{m_context, m_prototypeObject, "scroll", scroll, 2};
  ObjectFunction m_scrollTo{m_context, m_prototypeObject, "scrollTo", scroll, 2};
  ObjectFunction m_scrollBy{m_context, m_prototypeObject, "scrollBy", scrollBy, 2};

#if IS_TEST
  ObjectFunction m_profile{m_context, m_prototypeObject, "profile", profile, 0};
#endif

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
  DEFINE_HOST_CLASS_PROPERTY(18,
                             nodeName,
                             tagName,
                             className,
                             offsetLeft,
                             offsetTop,
                             offsetWidth,
                             offsetHeight,
                             clientWidth,
                             clientHeight,
                             clientTop,
                             clientLeft,
                             scrollTop,
                             scrollLeft,
                             scrollHeight,
                             scrollWidth,
                             children,
                             innerHTML,
                             outerHTML);
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
      : HostObject(context, "BoundingClientRect"),
        m_nativeBoundingClientRect(nativeBoundingClientRect){

        };

  DEFINE_HOST_OBJECT_PROPERTY(8, x, y, width, height, top, right, bottom, left);

 private:
  NativeBoundingClientRect* m_nativeBoundingClientRect{nullptr};
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_ELEMENT_H
