/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "all_collection.h"
#include "bindings/jsc/js_context.h"
#include "bindings/jsc/macros.h"
#include "element.h"
#include "node.h"

#include "bindings/jsc/DOM/elements/anchor_element.h"
#include "bindings/jsc/DOM/elements/animation_player_element.h"
#include "bindings/jsc/DOM/elements/audio_element.h"
#include "bindings/jsc/DOM/elements/canvas_element.h"
#include "bindings/jsc/DOM/elements/iframe_element.h"
#include "bindings/jsc/DOM/elements/image_element.h"
#include "bindings/jsc/DOM/elements/input_element.h"
#include "bindings/jsc/DOM/elements/object_element.h"
#include "bindings/jsc/DOM/elements/video_element.h"

namespace kraken::binding::jsc {

struct NativeDocument;

class JSDocument : public JSNode {
public:
  static std::unordered_map<JSContext *, JSDocument *> instanceMap;
  static JSDocument *instance(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

private:
protected:
  JSDocument() = delete;
  JSDocument(JSContext *context);
  ~JSDocument();
};

class DocumentCookie {
public:
  DocumentCookie() = default;

  std::string getCookie();
  void setCookie(std::string &str);

private:
  std::unordered_map<std::string, std::string> cookiePairs;
};

class DocumentInstance : public JSNode::NodeInstance {
public:
  DEFINE_OBJECT_PROPERTY(Document, 10, createElement, body, createTextNode, createComment, nodeName, getElementById,
                         documentElement, getElementsByTagName, all, cookie)

  static DocumentInstance *instance(JSContext *context);

  static JSValueRef createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef createTextNode(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef createComment(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getElementById(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getElementsByTagName(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                         size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  DocumentInstance() = delete;
  explicit DocumentInstance(JSDocument *document);
  ~DocumentInstance();
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

  void removeElementById(std::string &id, ElementInstance *element);
  void addElementById(std::string &id, ElementInstance *element);

  NativeDocument *nativeDocument;
  std::unordered_map<std::string, std::vector<ElementInstance *>> elementMapById;

  ElementInstance *body;

private:
  JSFunctionHolder m_createElement{context, this, "createElement", createElement};
  JSFunctionHolder m_createTextNode{context, this, "createTextNode", createTextNode};
  JSFunctionHolder m_createComment{context, this, "createComment", createComment};
  JSFunctionHolder m_getElementById{context, this, "getElementById", getElementById};
  JSFunctionHolder m_getElementsByTagName{context, this, "getElementsByTagName", getElementsByTagName};
  DocumentCookie m_cookie;
};

struct NativeDocument {
  NativeDocument() = delete;
  explicit NativeDocument(NativeNode *nativeNode) : nativeNode(nativeNode){};

  NativeNode *nativeNode;
};

void bindDocument(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_DOCUMENT_H
