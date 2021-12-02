/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include <regex>
#include "all_collection.h"
#include "bindings/qjs/js_context.h"
#include "comment_node.h"
#include "dart_methods.h"
#include "document_fragment.h"
#include "element.h"
#include "event.h"
#include "text_node.h"

#include "bindings/qjs/dom/elements/image_element.h"
#include "elements/.gen/anchor_element.h"
#include "elements/.gen/canvas_element.h"
#include "elements/.gen/input_element.h"
#include "elements/.gen/object_element.h"
#include "elements/.gen/script_element.h"
#include "elements/template_element.h"

#include "events/.gen/close_event.h"
#include "events/.gen/gesture_event.h"
#include "events/.gen/input_event.h"
#include "events/.gen/intersection_change.h"
#include "events/.gen/media_error_event.h"
#include "events/.gen/message_event.h"
#include "events/.gen/mouse_event.h"
#include "events/.gen/popstate_event.h"
#include "events/touch_event.h"

namespace kraken::binding::qjs {

void traverseNode(NodeInstance* node, TraverseHandler handler) {
  bool shouldExit = handler(node);
  if (shouldExit)
    return;

  QjsContext* ctx = node->context()->ctx();
  int childNodesLen = arrayGetLength(ctx, node->childNodes);

  if (childNodesLen != 0) {
    for (int i = 0; i < childNodesLen; i++) {
      JSValue n = JS_GetPropertyUint32(ctx, node->childNodes, i);
      auto* nextNode = static_cast<NodeInstance*>(JS_GetOpaque(n, Node::classId(n)));
      traverseNode(nextNode, handler);

      JS_FreeValue(node->context()->ctx(), n);
    }
  }
}

std::once_flag kDocumentInitOnceFlag;

void bindDocument(std::unique_ptr<JSContext>& context) {
  auto* documentConstructor = Document::instance(context.get());
  context->defineGlobalProperty("Document", documentConstructor->classObject);
  JSValue documentInstance = JS_CallConstructor(context->ctx(), documentConstructor->classObject, 0, nullptr);
  context->defineGlobalProperty("document", documentInstance);
}

JSClassID Document::kDocumentClassID{0};

Document::Document(JSContext* context) : Node(context, "Document") {
  std::call_once(kDocumentInitOnceFlag, []() { JS_NewClassID(&kDocumentClassID); });
  JS_SetPrototype(m_ctx, m_prototypeObject, Node::instance(m_context)->prototype());
  if (!document_registered) {
    defineElement("img", ImageElement::instance(m_context));
    defineElement("a", AnchorElement::instance(m_context));
    defineElement("canvas", CanvasElement::instance(m_context));
    defineElement("input", InputElement::instance(m_context));
    defineElement("object", ObjectElement::instance(m_context));
    defineElement("script", ScriptElement::instance(m_context));
    defineElement("template", TemplateElement::instance(m_context));
    document_registered = true;
  }

  if (!event_registered) {
    event_registered = true;
    Event::defineEvent(EVENT_INPUT,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new InputEventInstance(InputEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_MEDIA_ERROR, [](JSContext* context, void* nativeEvent) -> EventInstance* {
      return new MediaErrorEventInstance(MediaErrorEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent));
    });
    Event::defineEvent(EVENT_MESSAGE,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new MessageEventInstance(MessageEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_CLOSE,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new CloseEventInstance(CloseEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_INTERSECTION_CHANGE, [](JSContext* context, void* nativeEvent) -> EventInstance* {
      return new IntersectionChangeEventInstance(IntersectionChangeEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent));
    });
    Event::defineEvent(EVENT_TOUCH_START,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new TouchEventInstance(TouchEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_TOUCH_END,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new TouchEventInstance(TouchEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_TOUCH_MOVE,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new TouchEventInstance(TouchEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_TOUCH_CANCEL,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new TouchEventInstance(TouchEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_SWIPE,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new GestureEventInstance(GestureEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_PAN,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new GestureEventInstance(GestureEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_LONG_PRESS,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new GestureEventInstance(GestureEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_SCALE,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new GestureEventInstance(GestureEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_CLICK,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new MouseEventInstance(MouseEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_CANCEL,
                       [](JSContext* context, void* nativeEvent) -> EventInstance* { return new MouseEventInstance(MouseEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent)); });
    Event::defineEvent(EVENT_POPSTATE, [](JSContext* context, void* nativeEvent) -> EventInstance* {
      return new PopStateEventInstance(PopStateEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent));
    });
  }
}

JSClassID Document::classId() {
  return kDocumentClassID;
}

JSValue Document::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  auto* instance = new DocumentInstance(this);
  return instance->instanceObject;
}

JSValue Document::createEvent(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to argumentCount: 1 argument required, but only 0 present.");
  }

  JSValue eventTypeValue = argv[0];
  if (!JS_IsString(eventTypeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to createEvent: type should be a string.");
  }
  const char* c_eventType = JS_ToCString(ctx, eventTypeValue);
  JS_FreeCString(ctx, c_eventType);
  std::string eventType = std::string(c_eventType);
  if (eventType == "Event") {
    std::unique_ptr<NativeString> nativeEventType = jsValueToNativeString(ctx, eventTypeValue);
    auto nativeEvent = new NativeEvent{nativeEventType.release()};

    auto document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
    auto e = Event::buildEventInstance(eventType, document->context(), nativeEvent, false);
    return e->instanceObject;
  } else {
    return JS_NULL;
  }
}

JSValue Document::createElement(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to createElement: 1 argument required, but only 0 present.");
  }

  JSValue tagNameValue = argv[0];
  if (!JS_IsString(tagNameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to createElement: tagName should be a string.");
  }

  auto document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
  auto* context = static_cast<JSContext*>(JS_GetContextOpaque(ctx));
  std::string tagName = jsValueToStdString(ctx, tagNameValue);
  JSValue constructor = static_cast<Document*>(document->prototype())->getElementConstructor(document->m_context, tagName);

  JSValue element = JS_CallConstructor(ctx, constructor, argc, argv);
  return element;
}

JSValue Document::createTextNode(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'createTextNode' on 'Document': 1 argument required, but only 0 present.");
  }

  auto* document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
  JSValue textNode = JS_CallConstructor(ctx, TextNode::instance(document->m_context)->classObject, argc, argv);
  return textNode;
}
JSValue Document::createDocumentFragment(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
  return JS_CallConstructor(ctx, DocumentFragment::instance(document->m_context)->classObject, 0, nullptr);
}
JSValue Document::createComment(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
  JSValue commentNode = JS_CallConstructor(ctx, Comment::instance(document->m_context)->classObject, argc, argv);
  return commentNode;
}
JSValue Document::getElementById(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'getElementById' on 'Document': 1 argument required, but only 0 present.");
  }

  auto* document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
  JSValue idValue = argv[0];

  if (!JS_IsString(idValue))
    return JS_NULL;

  JSAtom id = JS_ValueToAtom(ctx, idValue);

  if (document->m_elementMapById.count(id) == 0) {
    JS_FreeAtom(ctx, id);
    return JS_NULL;
  };

  auto targetElementList = document->m_elementMapById[id];
  JS_FreeAtom(ctx, id);

  if (targetElementList.empty())
    return JS_NULL;

  for (auto& element : targetElementList) {
    if (element->isConnected())
      return JS_DupValue(ctx, element->instanceObject);
  }

  return JS_NULL;
}
JSValue Document::getElementsByTagName(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx,
                             "Uncaught TypeError: Failed to execute 'getElementsByTagName' on 'Document': 1 argument required, "
                             "but only 0 present.");
  }

  auto* document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
  JSValue tagNameValue = argv[0];
  std::string tagName = jsValueToStdString(ctx, tagNameValue);
  std::transform(tagName.begin(), tagName.end(), tagName.begin(), ::toupper);

  std::vector<ElementInstance*> elements;

  traverseNode(document->m_documentElement, [tagName, &elements](NodeInstance* node) {
    if (node->nodeType == NodeType::ELEMENT_NODE) {
      auto element = static_cast<ElementInstance*>(node);
      if (element->tagName() == tagName || tagName == "*") {
        elements.emplace_back(element);
      }
    }

    return false;
  });

  JSValue array = JS_NewArray(ctx);
  JSValue pushMethod = JS_GetPropertyStr(ctx, array, "push");

  for (auto& element : elements) {
    JS_Call(ctx, pushMethod, array, 1, &element->instanceObject);
  }

  JS_FreeValue(ctx, pushMethod);
  return array;
}

JSValue Document::getElementsByClassName(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'getElementsByClassName' on 'Document': 1 argument required, but only 0 present.");
  }

  auto* document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
  std::string className = jsValueToStdString(ctx, argv[0]);

  std::vector<ElementInstance*> elements;
  traverseNode(document->m_documentElement, [ctx, className, &elements](NodeInstance* node) {
    if (node->nodeType == NodeType::ELEMENT_NODE) {
      auto element = reinterpret_cast<ElementInstance*>(node);
      if (element->classNames()->containsAll(className)) {
        elements.emplace_back(element);
      }
    }

    return false;
  });

  JSValue array = JS_NewArray(ctx);
  JSValue pushMethod = JS_GetPropertyStr(ctx, array, "push");

  for (auto& element : elements) {
    JS_Call(ctx, pushMethod, array, 1, &element->instanceObject);
  }

  JS_FreeValue(ctx, pushMethod);
  return array;
}

void Document::defineElement(const std::string& tagName, Element* constructor) {
  elementConstructorMap[tagName] = constructor;
}

JSValue Document::getElementConstructor(JSContext* context, const std::string& tagName) {
  if (elementConstructorMap.count(tagName) > 0)
    return elementConstructorMap[tagName]->classObject;
  return Element::instance(context)->classObject;
}

bool Document::isCustomElement(const std::string& tagName) {
  return elementConstructorMap.count(tagName) > 0;
}

PROP_GETTER(DocumentInstance, nodeName)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NewString(ctx, "#document");
}
PROP_SETTER(DocumentInstance, nodeName)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(DocumentInstance, all)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
  auto all = new AllCollection(document->m_context);

  traverseNode(document->m_documentElement, [&all](NodeInstance* node) {
    all->internalAdd(node, nullptr);
    return false;
  });

  return all->jsObject;
}
PROP_SETTER(DocumentInstance, all)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(DocumentInstance, cookie)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
  std::string cookie = document->m_cookie->getCookie();
  return JS_NewString(ctx, cookie.c_str());
}
PROP_SETTER(DocumentInstance, cookie)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* document = static_cast<DocumentInstance*>(JS_GetOpaque(this_val, Document::classId()));
  std::string value = jsValueToStdString(ctx, argv[0]);
  document->m_cookie->setCookie(value);
  return JS_NULL;
}

std::string DocumentCookie::getCookie() {
  std::string result;
  size_t i = 0;
  for (auto& pair : cookiePairs) {
    result += pair.first + "=" + pair.second;
    i++;
    if (i < cookiePairs.size()) {
      result += "; ";
    }
  }

  return std::move(result);
}

inline std::string trim(std::string& str) {
  str.erase(0, str.find_first_not_of(' '));  // prefixing spaces
  str.erase(str.find_last_not_of(' ') + 1);  // surfixing spaces
  return str;
}

void DocumentCookie::setCookie(std::string& cookieStr) {
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

DocumentInstance::DocumentInstance(Document* document) : NodeInstance(document, NodeType::DOCUMENT_NODE, this, Document::classId(), "document") {
  m_cookie = std::make_unique<DocumentCookie>();
  m_instanceMap[Document::instance(m_context)] = this;
  m_eventTargetId = DOCUMENT_TARGET_ID;

  JSAtom htmlTagName = JS_NewAtom(m_ctx, "HTML");
  JSValue htmlTagValue = JS_AtomToValue(m_ctx, htmlTagName);
  JSValue htmlArgs[] = {htmlTagValue};
  JSValue documentElementValue = JS_CallConstructor(m_ctx, Element::instance(m_context)->classObject, 1, htmlArgs);
  m_documentElement = static_cast<ElementInstance*>(JS_GetOpaque(documentElementValue, Element::classId()));
  m_documentElement->parentNode = JS_DupValue(m_ctx, instanceObject);

  JSAtom documentElementTag = JS_NewAtom(m_ctx, "documentElement");
  JS_SetProperty(m_ctx, instanceObject, documentElementTag, documentElementValue);

  JS_FreeAtom(m_ctx, documentElementTag);
  JS_FreeAtom(m_ctx, htmlTagName);
  JS_FreeValue(m_ctx, htmlTagValue);

#if FLUTTER_BACKEND
  getDartMethod()->initHTML(m_context->getContextId(), m_documentElement->nativeEventTarget);
  getDartMethod()->initDocument(m_context->getContextId(), nativeEventTarget);
#endif
}

std::unordered_map<Document*, DocumentInstance*> DocumentInstance::m_instanceMap{};

DocumentInstance::~DocumentInstance() {}
void DocumentInstance::removeElementById(JSAtom id, ElementInstance* element) {
  if (m_elementMapById.count(id) > 0) {
    auto& list = m_elementMapById[id];
    JS_FreeValue(m_ctx, element->instanceObject);
    list_del(&element->documentLink.link);
    list.erase(std::find(list.begin(), list.end(), element));
  }
}
void DocumentInstance::addElementById(JSAtom id, ElementInstance* element) {
  if (m_elementMapById.count(id) == 0) {
    m_elementMapById[id] = std::vector<ElementInstance*>();
  }

  auto& list = m_elementMapById[id];
  auto it = std::find(list.begin(), list.end(), element);

  if (it == list.end()) {
    JS_DupValue(m_ctx, element->instanceObject);
    list_add_tail(&element->documentLink.link, &m_context->document_job_list);
    m_elementMapById[id].emplace_back(element);
  }
}

ElementInstance* DocumentInstance::documentElement() {
  return m_documentElement;
}

}  // namespace kraken::binding::qjs
