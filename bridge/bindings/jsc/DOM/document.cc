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

JSValueRef JSDocument::createEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                   size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to argumentCount: 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  const JSValueRef eventTypeRef = arguments[0];
  if (!JSValueIsString(ctx, eventTypeRef)) {
    throwJSError(ctx, "Failed to createEvent: type should be a string.", exception);
    return nullptr;
  }
  JSStringRef eventTypeStringRef = JSValueToStringCopy(ctx, eventTypeRef, exception);
  std::string &&eventType = JSStringToStdString(eventTypeStringRef);

  if (eventType == "Event") {
    auto nativeEvent = new NativeEvent(stringToNativeString(eventType));

    auto document = static_cast<DocumentInstance *>(JSObjectGetPrivate(thisObject));
    auto e = JSEvent::buildEventInstance(eventType, document->context, nativeEvent, false);
    return e->object;
  } else {
    return nullptr;
  }
}


JSValueRef JSDocument::createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx, "Failed to createElement: 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  const JSValueRef tagNameValue = arguments[0];
  if (!JSValueIsString(ctx, tagNameValue)) {
    throwJSError(ctx, "Failed to createElement: tagName should be a string.", exception);
    return nullptr;
  }

  JSStringRef tagNameStringRef = JSValueToStringCopy(ctx, tagNameValue, exception);
  std::string tagName = JSStringToStdString(tagNameStringRef);

  auto document = static_cast<DocumentInstance *>(JSObjectGetPrivate(thisObject));
  auto element = JSElement::buildElementInstance(document->context, tagName);
  return element->object;
}

JSValueRef JSDocument::createTextNode(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                      size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    throwJSError(ctx, "Failed to execute 'createTextNode' on 'Document': 1 argument required, but only 0 present.",
                 exception);
    return nullptr;
  }

  auto document = static_cast<DocumentInstance *>(JSObjectGetPrivate(thisObject));
  auto TextNode = JSTextNode::instance(document->context);
  auto textNodeInstance = JSObjectCallAsConstructor(ctx, TextNode->classObject, 1, arguments, exception);
  auto textNode = reinterpret_cast<JSTextNode::TextNodeInstance *>(JSObjectGetPrivate(textNodeInstance));
  return textNodeInstance;
}

JSValueRef JSDocument::createComment(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto document = static_cast<DocumentInstance *>(JSObjectGetPrivate(thisObject));
  auto CommentNode = JSCommentNode::instance(document->context);
  auto commentNodeInstance =
    JSObjectCallAsConstructor(ctx, CommentNode->classObject, argumentCount, arguments, exception);
  auto commentNode = reinterpret_cast<JSCommentNode::CommentNodeInstance *>(JSObjectGetPrivate(commentNodeInstance));
  return commentNodeInstance;
}

static std::atomic<bool> event_registered = false;
static std::atomic<bool> document_registered = false;

JSDocument::JSDocument(JSContext *context) : JSNode(context, "Document") {

  if (!event_registered) {
    event_registered = true;
    JSEvent::defineEvent(EVENT_INPUT, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new InputEventInstance(JSInputEvent::instance(context), reinterpret_cast<NativeInputEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_MEDIA_ERROR, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new MediaErrorEventInstance(JSMediaErrorEvent::instance(context),
                                         reinterpret_cast<NativeMediaErrorEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_MESSAGE, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new MessageEventInstance(JSMessageEvent::instance(context),
                                      reinterpret_cast<NativeMessageEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_CLOSE, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new CloseEventInstance(JSCloseEvent::instance(context), reinterpret_cast<NativeCloseEvent *>(nativeEvent));
      ;
    });
    JSEvent::defineEvent(EVENT_INTERSECTION_CHANGE, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new IntersectionChangeEventInstance(JSIntersectionChangeEvent::instance(context),
                                                 reinterpret_cast<NativeIntersectionChangeEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_TOUCH_START, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new TouchEventInstance(JSTouchEvent::instance(context), reinterpret_cast<NativeTouchEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_TOUCH_END, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new TouchEventInstance(JSTouchEvent::instance(context), reinterpret_cast<NativeTouchEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_TOUCH_MOVE, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new TouchEventInstance(JSTouchEvent::instance(context), reinterpret_cast<NativeTouchEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_TOUCH_CANCEL, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new TouchEventInstance(JSTouchEvent::instance(context), reinterpret_cast<NativeTouchEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_SWIPE, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new GestureEventInstance(JSGestureEvent::instance(context),
                                      reinterpret_cast<NativeGestureEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_PAN, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new GestureEventInstance(JSGestureEvent::instance(context),
                                      reinterpret_cast<NativeGestureEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_LONG_PRESS, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new GestureEventInstance(JSGestureEvent::instance(context),
                                      reinterpret_cast<NativeGestureEvent *>(nativeEvent));
    });
    JSEvent::defineEvent(EVENT_SCALE, [](JSContext *context, void *nativeEvent) -> EventInstance * {
      return new GestureEventInstance(JSGestureEvent::instance(context),
                                      reinterpret_cast<NativeGestureEvent *>(nativeEvent));
    });
  }
  if (!document_registered) {
    document_registered = true;

    JSElement::defineElement("img", [](JSContext *context) -> ElementInstance * {
      return new JSImageElement::ImageElementInstance(JSImageElement::instance(context));
    });
    JSElement::defineElement("a", [](JSContext *context) -> ElementInstance * {
      return new JSAnchorElement::AnchorElementInstance(JSAnchorElement::instance(context));
    });
    JSElement::defineElement("canvas", [](JSContext *context) -> ElementInstance * {
      return new JSCanvasElement::CanvasElementInstance(JSCanvasElement::instance(context));
    });
    JSElement::defineElement("input", [](JSContext *context) -> ElementInstance * {
      return new JSInputElement::InputElementInstance(JSInputElement::instance(context));
    });
    JSElement::defineElement("object", [](JSContext *context) -> ElementInstance* {
      return new JSObjectElement::ObjectElementInstance(JSObjectElement::instance(context));
    });
  }
}

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
  m_document = this;
  JSStringRef bodyTagName = JSStringCreateWithUTF8CString("BODY");
  auto Element = JSElement::instance(document->context);
  body = new ElementInstance(Element, bodyTagName, BODY_TARGET_ID);
  body->m_document = this;
  JSStringHolder bodyStringHolder = JSStringHolder(context, "body");
  JSStringHolder documentElementStringHolder = JSStringHolder(context, "documentElement");
  JSObjectSetProperty(ctx, object, bodyStringHolder.getString(), body->object, kJSPropertyAttributeReadOnly, nullptr);
  JSObjectSetProperty(ctx, object, documentElementStringHolder.getString(), body->object, kJSPropertyAttributeReadOnly,
                      nullptr);
  instanceMap[document->context] = this;
  getDartMethod()->initDocument(contextId, nativeDocument);
}

JSValueRef DocumentInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getDocumentPropertyMap();
  auto prototypePropertyMap = getDocumentPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSDocument>()->prototypeObject, nameStringHolder.getString(), exception);
  }

  if (propertyMap.count(name) == 0) {
    return NodeInstance::getProperty(name, exception);
  }

  DocumentProperty property = propertyMap[name];

  switch (property) {
  case DocumentProperty::documentElement:
  case DocumentProperty::body: {
    return nullptr;
  }
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
  case DocumentProperty::nodeName: {
    JSStringRef nodeName = JSStringCreateWithUTF8CString("#document");
    return JSValueMakeString(_hostClass->ctx, nodeName);
  }
  }

  return nullptr;
}

DocumentInstance::~DocumentInstance() {
  ::foundation::UICommandCallbackQueue::instance()->registerCallback(
    [](void *ptr) { delete reinterpret_cast<NativeDocument *>(ptr); }, nativeDocument);
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

JSValueRef JSDocument::getElementById(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
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

  auto document = reinterpret_cast<DocumentInstance *>(JSObjectGetPrivate(thisObject));
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

JSValueRef JSDocument::getElementsByTagName(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                            size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    throwJSError(ctx,
                 "Uncaught TypeError: Failed to execute 'getElementsByTagName' on 'Document': 1 argument required, "
                 "but only 0 present.",
                 exception);
    return nullptr;
  }

  auto document = reinterpret_cast<DocumentInstance *>(JSObjectGetPrivate(thisObject));
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

bool DocumentInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getDocumentPropertyMap();
  auto prototypePropertyMap = getDocumentPrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) return false;

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    if (property == DocumentProperty::cookie) {
      JSStringRef str = JSValueToStringCopy(ctx, value, exception);
      std::string cookie = JSStringToStdString(str);
      m_cookie.setCookie(cookie);
    }
    return true;
  } else {
    return NodeInstance::setProperty(name, value, exception);
  }
}

} // namespace kraken::binding::jsc
