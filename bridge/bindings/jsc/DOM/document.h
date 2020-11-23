/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

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
#include "bindings/jsc/DOM/elements/object_element.h"
#include "bindings/jsc/DOM/elements/video_element.h"

namespace kraken::binding::jsc {

struct NativeDocument;

class JSDocument : public JSNode {
public:
  static JSDocument *instance(JSContext *context);

  JSElement *getElementOfTagName(JSContext *context, std::string &tagName);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

private:
  std::unordered_map<std::string, JSElement *> m_elementMaps{
    {"a", JSAnchorElement::instance(context)},      {"animation-player", JSAnimationPlayerElement::instance(context)},
    {"audio", JSAudioElement::instance(context)},   {"video", JSVideoElement::instance(context)},
    {"canvas", JSCanvasElement::instance(context)}, {"div", JSElement::instance(context)},
    {"span", JSElement::instance(context)},         {"strong", JSElement::instance(context)},
    {"pre", JSElement::instance(context)},          {"p", JSElement::instance(context)},
    {"iframe", JSIframeElement::instance(context)}, {"object", JSObjectElement::instance(context)},
    {"img", JSImageElement::instance(context)}};

protected:
  JSDocument() = delete;
  JSDocument(JSContext *context);
};

class DocumentInstance : public JSNode::NodeInstance {
public:
  enum class DocumentProperty {
    kCreateElement,
    kBody,
    kCreateTextNode,
    kCreateComment,
    kNodeName,
    kGetElementById,
    kGetElementsByTagName
  };

  static DocumentInstance *instance(JSContext *context);

  static std::vector<JSStringRef> &getDocumentPropertyNames();
  static const std::unordered_map<std::string, DocumentProperty> &getPropertyMap();

  static JSValueRef createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef createTextNode(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef createComment(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getElementById(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getElementsByTagName(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  DocumentInstance() = delete;
  explicit DocumentInstance(JSDocument *document);
  ~DocumentInstance();
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

  void removeElementById(std::string &id, JSElement::ElementInstance *element);
  void addElementById(std::string &id, JSElement::ElementInstance *element);

  NativeDocument *nativeDocument;
  std::unordered_map<std::string, std::vector<JSElement::ElementInstance *>> elementMapById;

  JSElement::ElementInstance *body;

private:
  JSFunctionHolder m_createElement{context, this, "createElement", createElement};
  JSFunctionHolder m_createTextNode{context, this, "createTextNode", createTextNode};
  JSFunctionHolder m_createComment{context, this, "createComment", createComment};
  JSFunctionHolder m_getElementById{context, this, "getElementById", getElementById};
  JSFunctionHolder m_getElementsByTagName{context, this, "getElementsByTagName", getElementsByTagName};
};

struct NativeDocument {
  NativeDocument() = delete;
  explicit NativeDocument(NativeNode *nativeNode) : nativeNode(nativeNode){};

  NativeNode *nativeNode;
};

void bindDocument(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_DOCUMENT_H
