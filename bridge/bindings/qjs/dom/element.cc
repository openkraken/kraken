/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "document.h"
#include "dart_methods.h"

namespace kraken::binding::qjs {

void bindElement(std::unique_ptr<JSContext> &context) {
  auto *constructor = Element::instance(context.get());
  context->defineGlobalProperty("Element", constructor->classObject);
}

OBJECT_INSTANCE_IMPL(Element);

static inline bool isNumberIndex(std::string &name) {
  if (name.empty()) return false;
  char f = name[0];
  return f >= '0' && f <= '9';
}

JSValue ElementAttributes::getAttribute(std::string &name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return JS_NULL;
  }

  return m_attributes[name];
}

JSValue ElementAttributes::setAttribute(std::string &name, JSValue value) {
  bool numberIndex = isNumberIndex(name);

  JS_DupValue(m_ctx, value);

  if (numberIndex) {
    return JS_ThrowTypeError(m_ctx,"Failed to execute 'setAttribute' on 'Element': '%s' is not a valid attribute name.", name.c_str());
  }

  m_attributes[name] = value;

  return JS_NULL;
}

bool ElementAttributes::hasAttribute(std::string &name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return false;
  }

  return m_attributes.count(name) > 0;
}

void ElementAttributes::removeAttribute(std::string &name) {
  JSValue &value = m_attributes[name];
  JS_FreeValue(m_ctx, value);
  m_attributes.erase(name);
}

JSValue Element::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  if (argc == 0) return JS_ThrowTypeError(ctx, "Illegal constructor");
  JSValue &tagName = argv[0];

  if (!JS_IsString(tagName)) {
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  }

  const char *cName = JS_ToCString(ctx, tagName);
  std::string name = std::string(cName);

  ElementInstance *element;
  if (elementCreatorMap.count(name) > 0) {
    element = elementCreatorMap[name](this, tagName);
  } else {
    // Fallback to default Element class
    element = new ElementInstance(this, tagName);
  }

  JS_FreeCString(m_ctx, cName);

  return element->instanceObject;
}

JSValue Element::getBoundingClientRect(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  getDartMethod()->flushUICommand();
  return element->callNativeMethods("getBoundingClientRect", 0, nullptr);
}

JSValue Element::hasAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'hasAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue &nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  auto *attributes = element->m_attributes;

  const char* cname = JS_ToCString(ctx, nameValue);
  std::string name = std::string(cname);

  JSValue result = JS_NewBool(ctx, attributes->hasAttribute(name));
  JS_FreeCString(ctx, cname);

  return result;
}

JSValue Element::setAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc != 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': 2 arguments required, but only %d present", argc);
  }

  JSValue &nameValue = argv[0];
  JSValue &attributeValue = argv[1];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  std::string name = jsValueToStdString(ctx, nameValue);
  std::transform(name.begin(), name.end(), name.begin(), ::tolower);

  auto *attributes = element->m_attributes;

  if (attributes->hasAttribute(name)) {
    JSValue oldValue = attributes->getAttribute(name);
    JSValue exception = attributes->setAttribute(name, attributeValue);
    if (JS_IsException(exception)) return exception;
    element->_didModifyAttribute(name, oldValue, attributeValue);
  } else {
    JSValue exception = attributes->setAttribute(name, attributeValue);
    if (JS_IsException(exception)) return exception;
    JSValue oldValue = JS_NULL;
    element->_didModifyAttribute(name, oldValue, attributeValue);
  }

  NativeString *args_01 = stringToNativeString(name);
  NativeString *args_02 = jsValueToNativeString(ctx, attributeValue);

  ::foundation::UICommandBuffer::instance(element->m_context->getContextId())
    ->addCommand(element->eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);

  return JS_NULL;
}

JSValue Element::getAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'getAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue &nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  std::string name = jsValueToStdString(ctx, nameValue);

  auto *attributes = element->m_attributes;

  if (attributes->hasAttribute(name)) {
    return attributes->getAttribute(name);
  }

  return JS_NULL;
}

JSValue Element::removeAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue &nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeAttribute' on 'Element': name attribute is not valid.");
  }

  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  std::string name = jsValueToStdString(ctx, nameValue);
  auto *attributes = element->m_attributes;

  if (attributes->hasAttribute(name)) {
    JSValue idRef = attributes->getAttribute(name);
    element->m_attributes->removeAttribute(name);
    JSValue newValue = JS_NULL;
    element->_didModifyAttribute(name, idRef, newValue);

    NativeString *args_01 = stringToNativeString(name);
    ::foundation::UICommandBuffer::instance(element->m_context->getContextId())
      ->addCommand(element->eventTargetId, UICommand::removeProperty, *args_01, nullptr);
  }

  return JS_NULL;
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
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  return element->m_style->instanceObject;
}

PROP_SETTER(Element, style)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, attributes)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_SETTER(Element, attributes)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, nodeName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  std::string tagName = element->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

PROP_SETTER(Element, nodeName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, tagName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  std::string tagName = element->tagName();
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
