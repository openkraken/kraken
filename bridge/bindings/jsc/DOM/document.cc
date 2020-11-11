/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "element.h"
#include "text_node.h"
#include "comment_node.h"
#include "bindings/jsc/DOM/elements/anchor_element.h"
#include <mutex>

namespace kraken::binding::jsc {

void bindDocument(std::unique_ptr<JSContext> &context) {
  auto document = new JSDocument(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Document", document->classObject);
  auto documentObjectRef =
    document->instanceConstructor(context->context(), document->classObject, 0, nullptr, nullptr);
  JSC_GLOBAL_SET_PROPERTY(context, "document", documentObjectRef);
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

  auto document = static_cast<JSDocument *>(JSObjectGetPrivate(function));
  auto element = getElementOfTagName(document->context, tagName);
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

  auto document = static_cast<JSDocument *>(JSObjectGetPrivate(function));
  auto textNode = JSTextNode::instance(document->context);
  auto textNodeInstance = JSObjectCallAsConstructor(ctx, textNode->classObject, 1, arguments, exception);
  return textNodeInstance;
}

JSValueRef JSDocument::createComment(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto document = static_cast<JSDocument *>(JSObjectGetPrivate(function));
  auto commentNode = JSCommentNode::instance(document->context);
  auto commentNodeInstance = JSObjectCallAsConstructor(ctx, commentNode->classObject, argumentCount, arguments, exception);
  return commentNodeInstance;
}

JSDocument::JSDocument(JSContext *context) : JSNode(context, "Document") {}

JSObjectRef JSDocument::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                            const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new DocumentInstance(this);
  return instance->object;
}

JSElement *JSDocument::getElementOfTagName(JSContext *context, std::string &tagName) {
  static std::unordered_map<std::string, JSElement*> elementMap {
      {"a", JSAnchorElement::instance(context)},
      {"div", JSElement::instance(context)}
  };
  return elementMap[tagName];
}

JSDocument::DocumentInstance::DocumentInstance(JSDocument *document) : NodeInstance(document, NodeType::DOCUMENT_NODE) {
  auto elementConstructor = JSElement::instance(document->context);
  JSStringRef bodyTagName = JSStringCreateWithUTF8CString("BODY");
  const JSValueRef arguments[] = {JSValueMakeString(document->ctx, bodyTagName),
                                  JSValueMakeNumber(document->ctx, BODY_TARGET_ID)};
  body = JSObjectCallAsConstructor(document->ctx, elementConstructor->classObject, 2, arguments, nullptr);
  JSValueProtect(document->ctx, body);
}

JSValueRef JSDocument::DocumentInstance::getProperty(std::string &name, JSValueRef *exception) {
  if (name == "createElement") {
    if (_createElement == nullptr) {
      _createElement = propertyBindingFunction(_hostClass->context, this, "createElement", createElement);
    }
    return _createElement;
  } else if (name == "body") {
    return body;
  } else if (name == "createTextNode") {
    if (_createTextNode == nullptr) {
      _createTextNode = propertyBindingFunction(_hostClass->context, this, "createTextNode", createTextNode);
    }
    return _createTextNode;
  } else if (name == "createComment") {
    if (_createComment == nullptr) {
      _createComment = propertyBindingFunction(_hostClass->context, this, "createComment", createComment);
    }
    return _createComment;
  } else if (name == "nodeName") {
    JSStringRef nodeName = JSStringCreateWithUTF8CString("#document");
    return JSValueMakeString(_hostClass->ctx, nodeName);
  }

  return JSNode::NodeInstance::getProperty(name, exception);
}

JSDocument::DocumentInstance::~DocumentInstance() {
  JSValueUnprotect(_hostClass->ctx, body);
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

} // namespace kraken::binding::jsc
