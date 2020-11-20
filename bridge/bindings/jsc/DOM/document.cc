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

JSDocument * JSDocument::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSDocument *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSDocument(context);
  }
  return instanceMap[context];
}

JSValueRef JSDocument::createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
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

  auto document = static_cast<JSDocument::DocumentInstance *>(JSObjectGetPrivate(function));
  auto Document = reinterpret_cast<JSDocument*>(document->_hostClass);
  auto element = Document->getElementOfTagName(document->context, tagName);

  if (element == nullptr) {
    element = JSElement::instance(document->context);
  }

  auto elementInstance = JSObjectCallAsConstructor(ctx, element->classObject, 1, arguments, exception);
  return elementInstance;
}

JSValueRef JSDocument::createTextNode(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                      size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'createTextNode' on 'Document': 1 argument required, but only 0 present.",
                    exception);
    return nullptr;
  }

  auto document = static_cast<JSDocument::DocumentInstance *>(JSObjectGetPrivate(function));
  auto textNode = JSTextNode::instance(document->context);
  auto textNodeInstance = JSObjectCallAsConstructor(ctx, textNode->classObject, 1, arguments, exception);
  return textNodeInstance;
}

JSValueRef JSDocument::createComment(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto document = static_cast<JSDocument::DocumentInstance *>(JSObjectGetPrivate(function));
  auto commentNode = JSCommentNode::instance(document->context);
  auto commentNodeInstance =
    JSObjectCallAsConstructor(ctx, commentNode->classObject, argumentCount, arguments, exception);
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

JSDocument::DocumentInstance::DocumentInstance(JSDocument *document)
  : NodeInstance(document, NodeType::DOCUMENT_NODE), nativeDocument(new NativeDocument(nativeNode)) {
  auto elementConstructor = JSElement::instance(document->context);
  JSStringRef bodyTagName = JSStringCreateWithUTF8CString("BODY");
  const JSValueRef arguments[] = {JSValueMakeString(document->ctx, bodyTagName),
                                  JSValueMakeNumber(document->ctx, BODY_TARGET_ID)};
  m_body = JSObjectCallAsConstructor(document->ctx, elementConstructor->classObject, 2, arguments, nullptr);
  JSValueProtect(document->ctx, m_body);
}

JSValueRef JSDocument::DocumentInstance::getProperty(std::string &name, JSValueRef *exception) {
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
    return m_body;
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
  }

  return nullptr;
}

JSDocument::DocumentInstance::~DocumentInstance() {
  if (context->isValid()) {
    JSValueUnprotect(_hostClass->ctx, m_body);
  }
  delete nativeDocument;
}

void JSDocument::DocumentInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  JSNode::NodeInstance::getPropertyNames(accumulator);

  for (auto &property : getDocumentPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::array<JSStringRef, 4> &JSDocument::DocumentInstance::getDocumentPropertyNames() {
  static std::array<JSStringRef, 4> propertyNames{
    JSStringCreateWithUTF8CString("body"),
    JSStringCreateWithUTF8CString("createElement"),
    JSStringCreateWithUTF8CString("createTextNode"),
    JSStringCreateWithUTF8CString("createComment"),
  };
  return propertyNames;
}

const std::unordered_map<std::string, JSDocument::DocumentInstance::DocumentProperty> &
JSDocument::DocumentInstance::getPropertyMap() {
  static const std::unordered_map<std::string, DocumentProperty> propertyMap{
    {"body", DocumentProperty::kBody},
    {"createElement", DocumentProperty::kCreateElement},
    {"createTextNode", DocumentProperty::kCreateTextNode},
    {"createComment", DocumentProperty::kCreateComment}};
  return propertyMap;
}

} // namespace kraken::binding::jsc
