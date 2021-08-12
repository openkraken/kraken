/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "element.h"
#include "text_node.h"
#include "comment_node.h"
#include "event.h"
#include "dart_methods.h"
#include "all_collection.h"

namespace kraken::binding::qjs {

void traverseNode(NodeInstance *node, TraverseHandler handler) {
  bool shouldExit = handler(node);
  if (shouldExit) return;

  if (!node->childNodes.empty()) {
    for (auto &n : node->childNodes) {
      traverseNode(n, handler);
    }
  }
}


std::once_flag kDocumentInitOnceFlag;

void bindDocument(std::unique_ptr<JSContext> &context) {
  auto *documentConstructor = Document::instance(context.get());
  JSValue documentInstance = JS_CallConstructor(context->ctx(), documentConstructor->classObject, 0, nullptr);
  context->defineGlobalProperty("Document", documentConstructor->classObject);
  context->defineGlobalProperty("document", documentInstance);
}

JSClassID Document::kDocumentClassID{0};

Document::Document(JSContext *context) : Node(context, "Document") {
  std::call_once(kDocumentInitOnceFlag, []() {
    JS_NewClassID(&kDocumentClassID);
  });
  JS_SetPrototype(m_ctx, m_prototypeObject, Node::instance(m_context)->prototype());
}

JSClassID Document::classId() {
  return kDocumentClassID;
}

OBJECT_INSTANCE_IMPL(Document);

JSValue Document::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  auto *instance = new DocumentInstance(this);
  return instance->instanceObject;
}

JSValue Document::createEvent(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
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
    NativeString *nativeEventType = jsValueToNativeString(ctx, eventTypeValue);
    auto nativeEvent = new NativeEvent{nativeEventType};

    auto document = static_cast<DocumentInstance *>(JS_GetOpaque(this_val, Document::classId()));
    auto e = Event::buildEventInstance(eventType, document->context(), nativeEvent, false);
    return e->instanceObject;
  } else {
    return JS_NULL;
  }
}

JSValue Document::createElement(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to createElement: 1 argument required, but only 0 present.");
  }

  JSValue tagNameValue = argv[0];
  if (!JS_IsString(tagNameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to createElement: tagName should be a string.");
  }

  auto document = static_cast<DocumentInstance *>(JS_GetOpaque(this_val, Document::classId()));
  JSValue element = JS_CallConstructor(ctx, Element::instance(document->context())->classObject, argc, argv);
  return element;
}

JSValue Document::createTextNode(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'createTextNode' on 'Document': 1 argument required, but only 0 present.");
  }

  auto *document = static_cast<DocumentInstance *>(JS_GetOpaque(this_val, Document::classId()));
  JSValue textNode = JS_CallConstructor(ctx, TextNode::instance(document->m_context)->classObject, argc, argv);
  return textNode;
}
JSValue Document::createComment(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *document = static_cast<DocumentInstance *>(JS_GetOpaque(this_val, Document::classId()));
  JSValue commentNode = JS_CallConstructor(ctx, Comment::instance(document->m_context)->classObject, argc, argv);
  return commentNode;
}
JSValue Document::getElementById(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'getElementById' on 'Document': 1 argument required, but only 0 present.");
  }

  auto *document = static_cast<DocumentInstance *>(JS_GetOpaque(this_val, Document::classId()));
  JSValue idValue = argv[0];

  if (!JS_IsString(idValue)) return JS_NULL;

  JSAtom id = JS_ValueToAtom(ctx, idValue);

  if (document->m_elementMapById.count(id) == 0) return JS_NULL;

  auto targetElementList = document->m_elementMapById[id];
  JS_FreeAtom(ctx, id);

  if (targetElementList.empty()) return JS_NULL;

  for (auto &element : targetElementList) {
    if (element->isConnected()) return JS_DupValue(ctx, element->instanceObject);
  }

  return JS_NULL;
}
JSValue Document::getElementsByTagName(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Uncaught TypeError: Failed to execute 'getElementsByTagName' on 'Document': 1 argument required, "
                 "but only 0 present.");
  }

  auto *document = static_cast<DocumentInstance *>(JS_GetOpaque(this_val, Document::classId()));
  JSValue tagNameValue = argv[0];
  std::string tagName = jsValueToStdString(ctx, tagNameValue);
  std::transform(tagName.begin(), tagName.end(), tagName.begin(), ::toupper);

  std::vector<ElementInstance *> elements;

  traverseNode(document->m_documentElement, [tagName, &elements](NodeInstance *node) {
    if (node->nodeType == NodeType::ELEMENT_NODE) {
      auto element = static_cast<ElementInstance *>(node);
      if (element->tagName() == tagName) {
        elements.emplace_back(element);
      }
    }

    return false;
  });

  JSValue array = JS_NewArray(ctx);
  JSValue pushMethod = JS_GetPropertyStr(ctx, array, "push");

  for (auto & element : elements) {
    JS_Call(ctx, pushMethod, array, 1, &element->instanceObject);
  }
  return array;
}

PROP_GETTER(Document, nodeName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NewString(ctx, "#document");
}
PROP_SETTER(Document, nodeName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Document, all)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *document = static_cast<DocumentInstance *>(JS_GetOpaque(this_val, Document::classId()));
  auto all = new AllCollection(document->m_context);

  traverseNode(document->m_documentElement, [&all](NodeInstance *node) {
    all->internalAdd(node, nullptr);
    return false;
  });

  return all->jsObject;
}
PROP_SETTER(Document, all)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Document, cookie)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}
PROP_SETTER(Document, cookie)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {  return JS_NULL;}

PROP_GETTER(Document, documentElement)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *document = static_cast<DocumentInstance *>(JS_GetOpaque(this_val, Document::classId()));
  return document->m_documentElement->instanceObject;
}
PROP_SETTER(Document, documentElement)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

DocumentInstance::DocumentInstance(Document *document): NodeInstance(document, NodeType::DOCUMENT_NODE, this, Document::classId(), "document") {
  m_instanceMap[Document::instance(m_context)] = this;

  JSAtom htmlTagName = JS_NewAtom(m_ctx, "HTML");
  JSValue htmlTagValue = JS_AtomToValue(m_ctx, htmlTagName);
  JSValue htmlArgs[] = {
    htmlTagValue
  };
  JSValue documentElementValue = JS_CallConstructor(m_ctx, Element::instance(m_context)->classObject, 1, htmlArgs);
  m_documentElement = static_cast<ElementInstance *>(JS_GetOpaque(documentElementValue, Element::classId()));
  m_documentElement->parentNode = this;

  JSAtom documentElementTag = JS_NewAtom(m_ctx, "documentElement");
  JS_SetProperty(m_ctx, instanceObject, documentElementTag, documentElementValue);

  JS_FreeAtom(m_ctx, documentElementTag);
  JS_FreeAtom(m_ctx, htmlTagName);
  JS_FreeValue(m_ctx, htmlTagValue);

#if FLUTTER_BACKEND
  getDartMethod()->initHTML(m_context->getContextId(), &m_documentElement->nativeEventTarget);
  getDartMethod()->initDocument(m_context->getContextId(), &nativeEventTarget);
#endif
}

std::unordered_map<Document *, DocumentInstance *> DocumentInstance::m_instanceMap {};

DocumentInstance::~DocumentInstance() {
  JS_FreeValue(m_ctx, m_documentElement->instanceObject);
}
void DocumentInstance::removeElementById(JSAtom id, ElementInstance *element) {
  if (m_elementMapById.count(id) > 0) {
    auto &list = m_elementMapById[id];
    JS_FreeValue(m_ctx, element->instanceObject);
    list_del(&element->documentLink.link);
    list.erase(std::find(list.begin(), list.end(), element));
  }
}
void DocumentInstance::addElementById(JSAtom id, ElementInstance *element) {
  if (m_elementMapById.count(id) == 0) {
    m_elementMapById[id] = std::vector<ElementInstance *>();
  }

  auto &list = m_elementMapById[id];
  auto it = std::find(list.begin(), list.end(), element);

  if (it == list.end()) {
    JS_DupValue(m_ctx, element->instanceObject);
    list_add_tail(&element->documentLink.link, &m_context->document_list);
    m_elementMapById[id].emplace_back(element);
  }
}


}
