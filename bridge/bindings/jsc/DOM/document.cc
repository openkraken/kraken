/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "comment_node.h"
#include "element.h"
#include "text_node.h"
#include <mutex>
#include <regex>
#include "foundation/ui_command_callback_queue.h"

namespace kraken::binding::jsc {

void bindDocument(std::unique_ptr<JSContext> &context) {
  auto document = JSDocument::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Document", document->classObject);
  auto documentObjectRef =
    document->instanceConstructor(context->context(), document->classObject, 0, nullptr, nullptr);
  JSC_GLOBAL_SET_PROPERTY(context, "document", documentObjectRef);
}

std::unordered_map<JSContext *, JSDocument *> JSDocument::instanceMap{};

JSDocument *JSDocument::instance(JSContext *context) {
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSDocument(context);
  }
  return instanceMap[context];
}

JSDocument::~JSDocument() {
  instanceMap.erase(context);
}

JSValueRef DocumentInstance::createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount != 1) {
    throwJSError(ctx, "Failed to createElement: only accept 1 parameter.", exception);
    return nullptr;
  }

  const JSValueRef tagNameValue = arguments[0];
  if (!JSValueIsString(ctx, tagNameValue)) {
    throwJSError(ctx, "Failed to createElement: tagName should be a string.", exception);
    return nullptr;
  }

  JSStringRef tagNameStringRef = JSValueToStringCopy(ctx, tagNameValue, exception);
  std::string tagName = JSStringToStdString(tagNameStringRef);

  auto document = static_cast<DocumentInstance *>(JSObjectGetPrivate(function));
  auto element = JSElement::buildElementInstance(document->context, tagName);
  element->document = document;
  return element->object;
}

JSValueRef DocumentInstance::createTextNode(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                            size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    throwJSError(ctx, "Failed to execute 'createTextNode' on 'Document': 1 argument required, but only 0 present.",
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

static std::unordered_map<JSContext *, DocumentInstance *> instanceMap{};

std::string DocumentCookie::getCookie() {
  std::string result;
  size_t i = 0;
  for (auto &pair : cookiePairs) {
    result += pair.first + "=" + pair.second;
    i++;
    if (i < cookiePairs.size()) {
      result += "; ";
    }
  }

  return std::move(result);
}

void DocumentCookie::setCookie(std::string &cookieStr) {
  trim(cookieStr);

  std::string key;
  std::string value;

  const std::regex cookie_regex("^[^=]*=([^;]*)");

  if (!cookieStr.find('=', 0)) {
    key = "";
    value = cookieStr;
  } else {
    size_t idx = cookieStr.find('=', 0);
    key = cookieStr.substr(0, idx);

    std::match_results<std::string::const_iterator> match_results;
    // Only allow to set a single cookie at a time
    // Find first cookie value if multiple cookie set
    if (std::regex_match(cookieStr, match_results, cookie_regex)) {
      if (match_results.size() == 2) {
        value = match_results[1];

        if (key.empty() && value.empty()) {
          return;
        }
      }
    }
  }

  cookiePairs[key] = value;
}

DocumentInstance *DocumentInstance::instance(JSContext *context) {
  return instanceMap[context];
}

DocumentInstance::DocumentInstance(JSDocument *document)
  : NodeInstance(document, NodeType::DOCUMENT_NODE, DOCUMENT_TARGET_ID),
    nativeDocument(new NativeDocument(nativeNode)) {
  JSStringRef bodyTagName = JSStringCreateWithUTF8CString("BODY");
  auto Element = JSElement::instance(document->context);
  body = new ElementInstance(Element, bodyTagName, BODY_TARGET_ID);
  body->document = this;
  JSValueProtect(document->ctx, body->object);
  instanceMap[document->context] = this;
  getDartMethod()->initDocument(contextId, nativeDocument);
}

JSValueRef DocumentInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getDocumentPropertyMap();
  if (propertyMap.count(name) == 0) {
    return NodeInstance::getProperty(name, exception);
  }

  DocumentProperty property = propertyMap[name];

  switch (property) {
  case DocumentProperty::all: {
    auto all = new JSAllCollection(context);

    traverseNode(body, [&all](NodeInstance *node) {
      all->internalAdd(node, nullptr);
      return false;
    });

    return all->jsObject;
  }
  case DocumentProperty::cookie: {
    std::string cookie = m_cookie.getCookie();
    return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(cookie.c_str()));
  }
  case DocumentProperty::createElement: {
    return m_createElement.function();
  }
  case DocumentProperty::documentElement:
  case DocumentProperty::body:
    return body->object;
  case DocumentProperty::createTextNode: {
    return m_createTextNode.function();
  }
  case DocumentProperty::createComment: {
    return m_createComment.function();
  }
  case DocumentProperty::nodeName: {
    JSStringRef nodeName = JSStringCreateWithUTF8CString("#document");
    return JSValueMakeString(_hostClass->ctx, nodeName);
  }
  case DocumentProperty::getElementById: {
    return m_getElementById.function();
  }
  case DocumentProperty::getElementsByTagName: {
    return m_getElementsByTagName.function();
  }
  }

  return nullptr;
}

DocumentInstance::~DocumentInstance() {
  ::foundation::UICommandCallbackQueue::instance(contextId)->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeDocument *>(ptr);
  }, nativeDocument);
  instanceMap.erase(context);
}

void DocumentInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  NodeInstance::getPropertyNames(accumulator);

  for (auto &property : getDocumentPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

void DocumentInstance::removeElementById(std::string &id, ElementInstance *element) {
  if (elementMapById.count(id) > 0) {
    auto &list = elementMapById[id];
    list.erase(std::find(list.begin(), list.end(), element));
  }
}

void DocumentInstance::addElementById(std::string &id, ElementInstance *element) {
  if (elementMapById.count(id) == 0) {
    elementMapById[id] = std::vector<ElementInstance *>();
  }

  auto &list = elementMapById[id];
  auto it = std::find(list.begin(), list.end(), element);

  if (it == list.end()) {
    elementMapById[id].emplace_back(element);
  }
}

JSValueRef DocumentInstance::getElementById(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                            size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(
      ctx,
      "Uncaught TypeError: Failed to execute 'getElementById' on 'Document': 1 argument required, but only 0 present.",
      exception);
    return nullptr;
  }

  JSStringRef idStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string id = JSStringToStdString(idStringRef);
  if (id.empty()) return nullptr;

  auto document = reinterpret_cast<DocumentInstance *>(JSObjectGetPrivate(function));
  if (document->elementMapById.count(id) == 0) {
    return nullptr;
  }

  auto targetElementList = document->elementMapById[id];
  if (targetElementList.empty()) return nullptr;

  for (auto &element : targetElementList) {
    if (element->isConnected()) return element->object;
  }

  return nullptr;
}

JSValueRef DocumentInstance::getElementsByTagName(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                  size_t argumentCount, const JSValueRef *arguments,
                                                  JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx,
                    "Uncaught TypeError: Failed to execute 'getElementsByTagName' on 'Document': 1 argument required, "
                    "but only 0 present.",
                    exception);
    return nullptr;
  }

  auto document = reinterpret_cast<DocumentInstance *>(JSObjectGetPrivate(function));
  JSStringRef tagNameStringRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string tagName = JSStringToStdString(tagNameStringRef);
  std::transform(tagName.begin(), tagName.end(), tagName.begin(), ::toupper);

  std::vector<ElementInstance *> elements;

  traverseNode(document->body, [tagName, &elements](NodeInstance *node) {
    if (node->nodeType == NodeType::ELEMENT_NODE) {
      auto element = reinterpret_cast<ElementInstance *>(node);
      if (element->tagName() == tagName) {
        elements.emplace_back(element);
      }
    }

    return false;
  });

  JSValueRef elementArguments[elements.size()];

  for (int i = 0; i < elements.size(); i++) {
    elementArguments[i] = elements[i]->object;
  }

  return JSObjectMakeArray(ctx, elements.size(), elementArguments, exception);
}

void DocumentInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getDocumentPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    if (property == DocumentProperty::cookie) {
      JSStringRef str = JSValueToStringCopy(ctx, value, exception);
      std::string cookie = JSStringToStdString(str);
      m_cookie.setCookie(cookie);
    }
  } else {
    NodeInstance::setProperty(name, value, exception);
  }
}

} // namespace kraken::binding::jsc
