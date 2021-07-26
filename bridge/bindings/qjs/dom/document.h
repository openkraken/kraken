/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "node.h"
#include "element.h"

namespace kraken::binding::qjs {

void bindDocument(std::unique_ptr<JSContext> &context);

using TraverseHandler = std::function<bool(NodeInstance *)>;

void traverseNode(NodeInstance *node, TraverseHandler handler);

class Document : public Node {
public:
  static JSClassID kDocumentClassID;

  Document() = delete;
  Document(JSContext *context);

  static JSClassID classId();

  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;

  DEFINE_HOST_CLASS_PROPERTY(4, nodeName, all, cookie, documentElement);

  OBJECT_INSTANCE(Document);

  static JSValue createEvent(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue createElement(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue createTextNode(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue createComment(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue getElementById(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue getElementsByTagName(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

private:
  ObjectFunction m_createEvent{m_context, m_prototypeObject, "createEvent", createEvent, 1};
  ObjectFunction m_createElement{m_context, m_prototypeObject, "createElement", createElement, 1};
  ObjectFunction m_createTextNode{m_context, m_prototypeObject, "createTextNode", createTextNode, 1};
  ObjectFunction m_getElementById{m_context, m_prototypeObject, "getElementById", getElementById, 1};
  ObjectFunction m_getElementsByTagName{m_context, m_prototypeObject, "getElementsByTagName", getElementsByTagName, 1};
  friend DocumentInstance;
};

class DocumentInstance : public NodeInstance {
public:
  DocumentInstance() = delete;
  explicit DocumentInstance(Document *document);
  ~DocumentInstance();
  static std::unordered_map<Document *, DocumentInstance *> m_instanceMap;
  static DocumentInstance *instance(Document *document) {
    if (m_instanceMap.count(document) == 0) {
      m_instanceMap[document] = new DocumentInstance(document);
    }
    return m_instanceMap[document];
  }

private:
  void removeElementById(JSValue id, ElementInstance *element);
  void addElementById(JSValue id, ElementInstance *element);
  std::unordered_map<JSAtom, std::vector<ElementInstance *>> m_elementMapById;
  ElementInstance *m_documentElement{nullptr};

  friend Document;
  friend ElementInstance;
  friend JSContext;
};

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_DOCUMENT_H
