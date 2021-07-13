/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "document.h"
#include "dart_methods.h"

namespace kraken::binding::qjs {

OBJECT_INSTANCE_IMPL(Element);

JSValue Element::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  if (argc == 0) return JS_ThrowTypeError(ctx, "Illegal constructor");
  JSValue &tagName = argv[0];

  if (!JS_IsString(tagName)) {
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  }

  const char *cName = JS_ToCString(ctx, tagName);
  std::string name = std::string(cName);

  ElementInstance *elementInstance;
  if (elementCreatorMap.count(name) > 0) {
    elementInstance = elementCreatorMap[name](this, tagName);
  } else {
    // Fallback to default Element class
    elementInstance = new ElementInstance(this, tagName);
  }

  return elementInstance->instanceObject;
}

JSValue Element::getBoundingClientRect(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto elementInstance = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  getDartMethod()->flushUICommand();
//  assert_m(elementInstance->nativeElement->getBoundingClientRect != nullptr,
//           "Failed to execute getBoundingClientRect(): dart method is nullptr.");
//  NativeBoundingClientRect *nativeBoundingClientRect =
//      elementInstance->nativeElement->getBoundingClientRect(elementInstance->nativeElement);
//  auto boundingClientRect = new BoundingClientRect(elementInstance->context, nativeBoundingClientRect);
//  return boundingClientRect->jsObject;
  return JS_NULL;
}

JSValue Element::hasAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

JSValue Element::setAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

JSValue Element::getAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

JSValue Element::removeAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

JSValue Element::toBlob(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

JSValue Element::click(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

JSValue Element::scroll(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

JSValue Element::scrollBy(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

std::unordered_map<std::string, ElementCreator> Element::elementCreatorMap{};

void Element::defineElement(const std::string &tagName, ElementCreator creator) {
  if (elementCreatorMap.count(tagName) > 0) return;

  elementCreatorMap[tagName] = creator;
}

PROP_GETTER(Element, style)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *elementInstance = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  return elementInstance->m_style->instanceObject;
}

PROP_SETTER(Element, style)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, attributes)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, attributes)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, nodeName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *elementInstance = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  std::string tagName = elementInstance->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

PROP_SETTER(Element, nodeName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, tagName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *elementInstance = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  std::string tagName = elementInstance->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

PROP_SETTER(Element, tagName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, offsetLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, offsetLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, offsetTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, offsetTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, offsetWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, offsetWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, offsetHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, offsetHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, clientWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, clientWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, clientHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, clientHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, clientTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, clientTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, clientLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, clientLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, scrollTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, scrollTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, scrollLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, scrollLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, scrollHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, scrollHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, scrollWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, scrollWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, children)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, children)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

JSValue ElementInstance::getStringValueProperty(std::string &name) {
  return JSValue();
}

std::string ElementInstance::internalGetTextContent() {
  return NodeInstance::internalGetTextContent();
}

void ElementInstance::internalSetTextContent(JSValue content) {}

std::string ElementInstance::tagName() {
  const char *cTagName = JS_AtomToCString(m_ctx, m_tagName);
  std::string tagName = std::string(cTagName);
  std::transform(tagName.begin(), tagName.end(), tagName.begin(), ::toupper);
  return tagName;
}

std::string ElementInstance::getRegisteredTagName() {
  return std::string();
}

void ElementInstance::_notifyNodeRemoved(NodeInstance *node) {
  NodeInstance::_notifyNodeRemoved(node);
}

void ElementInstance::_notifyChildRemoved() {}

void ElementInstance::_notifyNodeInsert(NodeInstance *insertNode) {
  NodeInstance::_notifyNodeInsert(insertNode);
}

void ElementInstance::_notifyChildInsert() {}

void ElementInstance::_didModifyAttribute(std::string &name, JSValue &oldId, JSValue &newId) {}

void ElementInstance::_beforeUpdateId(JSValue &oldId, JSValue &newId) {}

ElementInstance::ElementInstance(Element *element, JSValue &tagName) :
    NodeInstance(element, NodeType::ELEMENT_NODE,
                 DocumentInstance::instance(
                     Document::instance(
                         element->m_context))),
    m_tagName(JS_ValueToAtom(m_ctx, tagName)) {
  NativeString *args_01 = jsValueToNativeString(m_ctx, tagName);
  ::foundation::UICommandBuffer::instance(m_context->getContextId())
      ->addCommand(eventTargetId, UICommand::createElement, *args_01, &nativeEventTarget);
}

}
