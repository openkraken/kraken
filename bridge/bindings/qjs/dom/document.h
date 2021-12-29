/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "element.h"
#include "frame_request_callback_collection.h"
#include "node.h"
#include "script_animation_controller.h"

namespace kraken::binding::qjs {

void bindDocument(std::unique_ptr<ExecutionContext>& context);

using TraverseHandler = std::function<bool(NodeInstance*)>;

void traverseNode(NodeInstance* node, TraverseHandler handler);

class Document : public Node {
 public:
  static JSClassID kDocumentClassID;

  Document() = delete;
  Document(ExecutionContext* context);

  static JSClassID classId();

  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  OBJECT_INSTANCE(Document);

  static JSValue createEvent(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue createElement(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue createTextNode(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue createDocumentFragment(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue createComment(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getElementById(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getElementsByTagName(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getElementsByClassName(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  JSValue getElementConstructor(ExecutionContext* context, const std::string& tagName);
  bool isCustomElement(const std::string& tagName);

 private:
  DEFINE_PROTOTYPE_READONLY_PROPERTY(nodeName);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(all);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(documentElement);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(children);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(head);

  DEFINE_PROTOTYPE_PROPERTY(cookie);
  DEFINE_PROTOTYPE_PROPERTY(body);

  DEFINE_PROTOTYPE_FUNCTION(createEvent, 1);
  DEFINE_PROTOTYPE_FUNCTION(createElement, 1);
  DEFINE_PROTOTYPE_FUNCTION(createDocumentFragment, 0);
  DEFINE_PROTOTYPE_FUNCTION(createTextNode, 1);
  DEFINE_PROTOTYPE_FUNCTION(createComment, 1);
  DEFINE_PROTOTYPE_FUNCTION(getElementById, 1);
  DEFINE_PROTOTYPE_FUNCTION(getElementsByTagName, 1);
  DEFINE_PROTOTYPE_FUNCTION(getElementsByClassName, 1);

  void defineElement(const std::string& tagName, Element* constructor);

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

  int32_t requestAnimationFrame(FrameCallback* frameCallback);
  void cancelAnimationFrame(uint32_t callbackId);
  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;

 private:
  void removeElementById(JSAtom id, ElementInstance* element);
  void addElementById(JSAtom id, ElementInstance* element);
  ElementInstance* getDocumentElement();
  std::unordered_map<JSAtom, std::vector<ElementInstance*>> m_elementMapById;
  ElementInstance* m_documentElement{nullptr};
  std::unique_ptr<DocumentCookie> m_cookie;

  ScriptAnimationController* m_scriptAnimationController;

  friend Document;
  friend ElementInstance;
  friend ExecutionContext;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_DOCUMENT_H
