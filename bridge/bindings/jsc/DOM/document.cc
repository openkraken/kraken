/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "bindings/jsc/DOM/elements/anchor_element.h"
#include "bindings/jsc/DOM/elements/animation_player_element.h"
#include "bindings/jsc/DOM/elements/audio_element.h"
#include "bindings/jsc/DOM/elements/video_element.h"
#include "bindings/jsc/DOM/elements/canvas_element.h"
#include "bindings/jsc/DOM/elements/iframe_element.h"
#include "comment_node.h"
#include "element.h"
#include "text_node.h"
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

  auto document = static_cast<JSDocument::DocumentInstance *>(JSObjectGetPrivate(function));
  auto element = getElementOfTagName(document->_hostClass->context, tagName);

  if (element == nullptr) {
    element = JSElement::instance(document->_hostClass->context);
  }

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

  auto document = static_cast<JSDocument::DocumentInstance *>(JSObjectGetPrivate(function));
  auto textNode = JSTextNode::instance(document->_hostClass->context);
  auto textNodeInstance = JSObjectCallAsConstructor(ctx, textNode->classObject, 1, arguments, exception);
  return textNodeInstance;
}

JSValueRef JSDocument::createComment(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto document = static_cast<JSDocument::DocumentInstance *>(JSObjectGetPrivate(function));
  auto commentNode = JSCommentNode::instance(document->_hostClass->context);
  auto commentNodeInstance =
    JSObjectCallAsConstructor(ctx, commentNode->classObject, argumentCount, arguments, exception);
  return commentNodeInstance;
}

JSDocument::JSDocument(JSContext *context) : JSNode(context, "Document") {}

JSObjectRef JSDocument::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                            const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new DocumentInstance(this);
  return instance->object;
}

JSElement *JSDocument::getElementOfTagName(JSContext *context, std::string &tagName) {
  static std::unordered_map<std::string, JSElement *> elementMap{
    {"a", JSAnchorElement::instance(context)},
    {"animation-player", JSAnimationPlayerElement::instance(context)},
    {"audio", JSAudioElement::instance(context)},
    {"video", JSVideoElement::instance(context)},
    {"canvas", JSCanvasElement::instance(context)},
    {"div", JSElement::instance(context)},
    {"span", JSElement::instance(context)},
    {"strong", JSElement::instance(context)},
    {"pre", JSElement::instance(context)},
    {"p", JSElement::instance(context)},
    {"iframe", JSIframeElement::instance(context)}};
  return elementMap[tagName];
}

JSDocument::DocumentInstance::DocumentInstance(JSDocument *document)
  : NodeInstance(document, NodeType::DOCUMENT_NODE), nativeDocument(new NativeDocument(nativeNode)) {
  auto elementConstructor = JSElement::instance(document->context);
  JSStringRef bodyTagName = JSStringCreateWithUTF8CString("BODY");
  const JSValueRef arguments[] = {JSValueMakeString(document->ctx, bodyTagName),
                                  JSValueMakeNumber(document->ctx, BODY_TARGET_ID)};
  body = JSObjectCallAsConstructor(document->ctx, elementConstructor->classObject, 2, arguments, nullptr);
  JSValueProtect(document->ctx, body);
}

JSValueRef JSDocument::DocumentInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getPropertyMap();
  if (!propertyMap.contains(name)) {
    return JSNode::NodeInstance::getProperty(name, exception);
  }

  DocumentProperty property = propertyMap[name];

  switch (property) {
  case DocumentProperty::kCreateElement: {
    if (_createElement == nullptr) {
      _createElement = propertyBindingFunction(_hostClass->context, this, "createElement", createElement);
    }
    return _createElement;
  }
  case DocumentProperty::kBody:
    return body;
  case DocumentProperty::kCreateTextNode: {
    if (_createTextNode == nullptr) {
      _createTextNode = propertyBindingFunction(_hostClass->context, this, "createTextNode", createTextNode);
    }
    return _createTextNode;
  }
  case DocumentProperty::kCreateComment: {
    if (_createComment == nullptr) {
      _createComment = propertyBindingFunction(_hostClass->context, this, "createComment", createComment);
    }
    return _createComment;
  }
  case DocumentProperty::kNodeName: {
    JSStringRef nodeName = JSStringCreateWithUTF8CString("#document");
    return JSValueMakeString(_hostClass->ctx, nodeName);
  }
  }

  return nullptr;
}

JSDocument::DocumentInstance::~DocumentInstance() {
  JSValueUnprotect(_hostClass->ctx, body);
  delete nativeDocument;
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

const std::unordered_map<std::string, JSDocument::DocumentInstance::DocumentProperty> &
JSDocument::DocumentInstance::getPropertyMap() {
  static const std::unordered_map<std::string, DocumentProperty> propertyMap{
    {"body", DocumentProperty::kBody},
    {"createElement", DocumentProperty::kCreateElement},
    {"createTextNode", DocumentProperty::kCreateTextNode},
    {"createComment", DocumentProperty::kCreateComment}};
  return propertyMap;
}

} // namespace kraken::binding::jsc
