/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include <unordered_map>
#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/host_object.h"
#include "node.h"
#include "style_declaration.h"

namespace kraken::binding::qjs {

void bindElement(std::unique_ptr<ExecutionContext>& context);

class Element;

using ElementCreator = Element* (*)(Element* element, std::string tagName);

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

// TODO: refactor for better W3C standard support and higher performance.
class ElementAttributes : public GarbageCollected<ElementAttributes> {
 public:
  static JSClassID classId;

  FORCE_INLINE const char* getHumanReadableName() const override { return "ElementAttributes"; }

  void dispose() const override;
  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;

  JSValue getAttribute(const std::string& name);
  JSValue setAttribute(const std::string& name, JSValue value);
  bool hasAttribute(std::string& name);
  void removeAttribute(std::string& name);
  void copyWith(ElementAttributes* attributes);
  std::shared_ptr<SpaceSplitString> className();
  std::string toString();

 private:
  std::unordered_map<std::string, JSValue> m_attributes;
  std::shared_ptr<SpaceSplitString> m_className{std::make_shared<SpaceSplitString>("")};
};

bool isJavaScriptExtensionElementInstance(ExecutionContext* context, JSValue instance);

class Element : public Node {
 public:
  static JSClassID classId;
  static Element* create(JSContext* ctx);

  DEFINE_FUNCTION(getBoundingClientRect);
  DEFINE_FUNCTION(hasAttribute);
  DEFINE_FUNCTION(setAttribute);
  DEFINE_FUNCTION(getAttribute);
  DEFINE_FUNCTION(removeAttribute);
  DEFINE_FUNCTION(toBlob);
  DEFINE_FUNCTION(click);
  DEFINE_FUNCTION(scroll);
  DEFINE_FUNCTION(scrollBy);

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
  DEFINE_PROTOTYPE_READONLY_PROPERTY(attributes);

  DEFINE_PROTOTYPE_PROPERTY(className);
  DEFINE_PROTOTYPE_PROPERTY(innerHTML);
  DEFINE_PROTOTYPE_PROPERTY(outerHTML);
  DEFINE_PROTOTYPE_PROPERTY(scrollTop);
  DEFINE_PROTOTYPE_PROPERTY(scrollLeft);

  JSValue internalGetTextContent() override;
  void internalSetTextContent(JSValue content) override;

  std::shared_ptr<SpaceSplitString> classNames();
  std::string tagName();
  std::string getRegisteredTagName();
  std::string outerHTML();
  std::string innerHTML();
  StyleDeclarationInstance* style();

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;

 protected:
  StyleDeclarationInstance* m_style{nullptr};
  ElementAttributes* m_attributes{nullptr};
 private:
  std::string m_tagName;
  void _notifyNodeRemoved(Node* node) override;
  void _notifyChildRemoved();
  void _notifyNodeInsert(Node* insertNode) override;
  void _notifyChildInsert();
  void _didModifyAttribute(std::string& name, JSValue oldId, JSValue newId);
  void _beforeUpdateId(JSValue oldIdValue, JSValue newIdValue);

  static JSClassExoticMethods exoticMethods;
  friend class Node;
};

struct PersistElement {
  Element* element;
  list_head link;
};

auto elementCreator = [](JSContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags) -> JSValue {
  if (argc == 0) {
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  }
  JSValue tagName = argv[0];

  if (!JS_IsString(tagName)) {
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  }

  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  std::string name = jsValueToStdString(ctx, tagName);

  Element* element = Element::create(ctx);

  auto* document = context->document();
//  auto* Document = Document::instance(context);
//  if (Document->isCustomElement(name)) {
//    return JS_CallConstructor(ctx, Document->getElementConstructor(context, name), argc, argv);
//  }
//
//  auto* element = new Element(this, name, true);
//  return element->jsObject;
};

const WrapperTypeInfo elementTypeInfo = {"Element", &nodeTypeInfo, elementCreator};

class BoundingClientRect : public GarbageCollected<BoundingClientRect> {
 public:
  BoundingClientRect() = delete;
  explicit BoundingClientRect(ExecutionContext* context, NativeBoundingClientRect* nativeBoundingClientRect) : GarbageCollected(), m_nativeBoundingClientRect(nativeBoundingClientRect){};

  const char* getHumanReadableName() const override { return "BoundingClientRect"; }

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
