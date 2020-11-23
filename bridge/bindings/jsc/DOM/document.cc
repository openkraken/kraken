/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "comment_node.h"
#include "element.h"
#include "text_node.h"
#include <mutex>

namespace kraken::binding::jsc {

void bindDocument(std::unique_ptr<JSContext> &context) {
  auto document = JSDocument::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Document", document->classObject);
  auto documentObjectRef =
    document->instanceConstructor(context->context(), document->classObject, 0, nullptr, nullptr);
  JSC_GLOBAL_SET_PROPERTY(context, "document", documentObjectRef);
}

JSDocument *JSDocument::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSDocument *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSDocument(context);
  }
  return instanceMap[context];
}

JSValueRef DocumentInstance::createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to createElement: only accept 1 parameter.", exception)
    return nullptr;
  }

  const JSValueRef tagNameValue = arguments[0];
  if (!JSValueIsString(ctx, tagNameValue)) {
    JSC_THROW_ERROR(ctx, "Failed to createElement: tagName should be a string.", exception);
    return nullptr;
  }

  JSStringRef tagNameStringRef = JSValueToStringCopy(ctx, tagNameValue, exception);
  std::string tagName = JSStringToStdString(tagNameStringRef);

  auto document = static_cast<DocumentInstance *>(JSObjectGetPrivate(function));
  auto Document = reinterpret_cast<JSDocument *>(document->_hostClass);
  auto Element = Document->getElementOfTagName(document->context, tagName);

  if (Element == nullptr) {
    Element = JSElement::instance(document->context);
  }

  auto element = new JSElement::ElementInstance(Element, tagName.c_str());
  element->document = document;
  return element->object;
}

JSValueRef DocumentInstance::createTextNode(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                            size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'createTextNode' on 'Document': 1 argument required, but only 0 present.",
                    exception);
    return nullptr;
  }

  auto document = static_cast<DocumentInstance *>(JSObjectGetPrivate(function));
  auto TextNode = JSTextNode::instance(document->context);
  auto textNodeInstance = JSObjectCallAsConstructor(ctx, TextNode->classObject, 1, arguments, exception);
  auto textNode = reinterpret_cast<JSTextNode::TextNodeInstance *>(JSObjectGetPrivate(textNodeInstance));
  textNode->document = document;
  return textNodeInstance;
}

JSValueRef DocumentInstance::createComment(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto document = static_cast<DocumentInstance *>(JSObjectGetPrivate(function));
  auto CommentNode = JSCommentNode::instance(document->context);
  auto commentNodeInstance =
    JSObjectCallAsConstructor(ctx, CommentNode->classObject, argumentCount, arguments, exception);
  auto commentNode = reinterpret_cast<JSCommentNode::CommentNodeInstance *>(JSObjectGetPrivate(commentNodeInstance));
  commentNode->document = document;
  return commentNodeInstance;
}

JSDocument::JSDocument(JSContext *context) : JSNode(context, "Document") {}

JSObjectRef JSDocument::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                            const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new DocumentInstance(this);
  return instance->object;
}

JSElement *JSDocument::getElementOfTagName(JSContext *context, std::string &tagName) {
  return m_elementMaps[tagName];
}

DocumentInstance::DocumentInstance(JSDocument *document)
  : NodeInstance(document, NodeType::DOCUMENT_NODE, DOCUMENT_TARGET_ID), nativeDocument(new NativeDocument(nativeNode)) {
  JSStringRef bodyTagName = JSStringCreateWithUTF8CString("BODY");
  auto Element = JSElement::instance(document->context);
  m_body = new JSElement::ElementInstance(Element, bodyTagName, BODY_TARGET_ID);
  m_body->document = this;
  JSValueProtect(document->ctx, m_body->object);
}

JSValueRef DocumentInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getPropertyMap();
  if (!propertyMap.contains(name)) {
    return JSNode::NodeInstance::getProperty(name, exception);
  }

  DocumentProperty property = propertyMap[name];

  switch (property) {
  case DocumentProperty::kCreateElement: {
    return m_createElement.function();
  }
  case DocumentProperty::kBody:
    return m_body->object;
  case DocumentProperty::kCreateTextNode: {
    return m_createTextNode.function();
  }
  case DocumentProperty::kCreateComment: {
    return m_createComment.function();
  }
  case DocumentProperty::kNodeName: {
    JSStringRef nodeName = JSStringCreateWithUTF8CString("#document");
    return JSValueMakeString(_hostClass->ctx, nodeName);
  }
  case DocumentProperty::kGetElementById: {
    return m_getElementById.function();
  }
  }

  return nullptr;
}

DocumentInstance::~DocumentInstance() {
  delete nativeDocument;
}

void DocumentInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  JSNode::NodeInstance::getPropertyNames(accumulator);

  for (auto &property : getDocumentPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::vector<JSStringRef> &DocumentInstance::getDocumentPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("body"), JSStringCreateWithUTF8CString("createElement"),
    JSStringCreateWithUTF8CString("createTextNode"), JSStringCreateWithUTF8CString("createComment"),
    JSStringCreateWithUTF8CString("getElementById")};
  return propertyNames;
}

const std::unordered_map<std::string, DocumentInstance::DocumentProperty> &DocumentInstance::getPropertyMap() {
  static const std::unordered_map<std::string, DocumentProperty> propertyMap{
    {"body", DocumentProperty::kBody},
    {"createElement", DocumentProperty::kCreateElement},
    {"createTextNode", DocumentProperty::kCreateTextNode},
    {"createComment", DocumentProperty::kCreateComment},
    {"getElementById", DocumentProperty::kGetElementById}};
  return propertyMap;
}

void DocumentInstance::removeElementById(std::string &id) {
  if (elementMapById.contains(id)) {
    elementMapById.erase(id);
  }
}

void DocumentInstance::addElementById(std::string &id, JSElement::ElementInstance *element) {
  elementMapById[id] = element;
}

JSValueRef DocumentInstance::getElementById(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                            size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    JSC_THROW_ERROR(
      ctx,
      "Uncaught TypeError: Failed to execute 'getElementById' on 'Document': 1 argument required, but only 0 present.",
      exception);
    return nullptr;
  }

  JSStringRef idStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string id = JSStringToStdString(idStringRef);
  if (id.empty()) return nullptr;

  auto document = reinterpret_cast<DocumentInstance *>(JSObjectGetPrivate(function));
  if (!document->elementMapById.contains(id)) {
    return nullptr;
  }

  auto targetElement = document->elementMapById[id];
  if (targetElement->isConnected()) return targetElement->object;
  return nullptr;
}

} // namespace kraken::binding::jsc
