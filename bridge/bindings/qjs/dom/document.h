/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "element.h"
#include "node.h"

namespace kraken::binding::qjs {

void bindDocument(std::unique_ptr<JSContext>& context);

using TraverseHandler = std::function<bool(NodeInstance*)>;

void traverseNode(NodeInstance* node, TraverseHandler handler);

class Document : public Node {
 public:
  static JSClassID kDocumentClassID;

  Document() = delete;
  Document(JSContext* context);

  static JSClassID classId();

  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  OBJECT_INSTANCE(Document);

  static JSValue createEvent(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue createElement(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue createTextNode(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue createDocumentFragment(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue createComment(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getElementById(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getElementsByTagName(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getElementsByClassName(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  JSValue getElementConstructor(JSContext* context, const std::string& tagName);
  bool isCustomElement(const std::string& tagName);

 private:
  DEFINE_PROTOTYPE_READONLY_PROPERTY(2, nodeName, all)
  DEFINE_PROTOTYPE_PROPERTY(1, cookie);

  void defineElement(const std::string& tagName, Element* constructor);

  ObjectFunction m_createEvent{m_context, m_prototypeObject, "createEvent", createEvent, 1};
  ObjectFunction m_createElement{m_context, m_prototypeObject, "createElement", createElement, 1};
  ObjectFunction m_createDocumentFragment{m_context, m_prototypeObject, "createDocumentFragment", createDocumentFragment, 0};
  ObjectFunction m_createTextNode{m_context, m_prototypeObject, "createTextNode", createTextNode, 1};
  ObjectFunction m_createComment{m_context, m_prototypeObject, "createComment", createComment, 1};
  ObjectFunction m_getElementById{m_context, m_prototypeObject, "getElementById", getElementById, 1};
  ObjectFunction m_getElementsByTagName{m_context, m_prototypeObject, "getElementsByTagName", getElementsByTagName, 1};
  ObjectFunction m_getElementsByClassName{m_context, m_prototypeObject, "getElementsByClassName", getElementsByClassName, 1};
  friend DocumentInstance;

  bool event_registered{false};
  bool document_registered{false};
  std::unordered_map<std::string, Element*> elementConstructorMap;
};

class DocumentCookie {
 public:
  DocumentCookie() = default;

  std::string getCookie();
  void setCookie(std::string& str);

 private:
  std::unordered_map<std::string, std::string> cookiePairs;
};

class DocumentInstance : public NodeInstance {
 public:
  DocumentInstance() = delete;
  explicit DocumentInstance(Document* document);
  ~DocumentInstance();
  static std::unordered_map<Document*, DocumentInstance*> m_instanceMap;
  ElementInstance* documentElement();
  static DocumentInstance* instance(Document* document) {
    if (m_instanceMap.count(document) == 0) {
      m_instanceMap[document] = new DocumentInstance(document);
    }
    return m_instanceMap[document];
  }

 private:
  void removeElementById(JSAtom id, ElementInstance* element);
  void addElementById(JSAtom id, ElementInstance* element);
  std::unordered_map<JSAtom, std::vector<ElementInstance*>> m_elementMapById;
  ElementInstance* m_documentElement{nullptr};
  std::unique_ptr<DocumentCookie> m_cookie;

  friend Document;
  friend ElementInstance;
  friend JSContext;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_DOCUMENT_H
