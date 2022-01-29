/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "text_node.h"
#include "document.h"

namespace kraken {

std::once_flag kTextNodeInitFlag;

void bindTextNode(std::unique_ptr<ExecutionContext>& context) {
  JSValue constructor = TextNode::constructor(context.get());
  JSValue prototype = TextNode::prototype(context.get());

  // Install readonly properties.
  INSTALL_READONLY_PROPERTY(TextNode, prototype, nodeName);

  // Install properties.
  INSTALL_PROPERTY(TextNode, prototype, data);
  INSTALL_PROPERTY(TextNode, prototype, nodeValue);

  context->defineGlobalProperty("Text", constructor);
}

JSClassID TextNode::classId{0};

JSValue TextNode::constructor(ExecutionContext* context) {
  return context->contextData()->constructorForType(&textNodeType);
}

JSValue TextNode::prototype(ExecutionContext* context) {
  return context->contextData()->prototypeForType(&textNodeType);
}

TextNode* TextNode::create(JSContext* ctx, JSValue textContent) {
  return makeGarbageCollected<TextNode>(textContent)->initialize<TextNode>(ctx, &classId);
}

TextNode::TextNode(JSValueConst textContent) {
  m_data = jsValueToStdString(m_ctx, textContent);
  std::unique_ptr<NativeString> args_01 = stringToNativeString(m_data);
  context()->uiCommandBuffer()->addCommand(eventTargetId(), UICommand::createTextNode, *args_01, nativeEventTarget);
}

IMPL_PROPERTY_GETTER(TextNode, data)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNode*>(JS_GetOpaque(this_val, TextNode::classId));
  return JS_NewString(ctx, textNode->m_data.c_str());
}
IMPL_PROPERTY_SETTER(TextNode, data)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNode*>(JS_GetOpaque(this_val, TextNode::classId));
  textNode->internalSetTextContent(argv[0]);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(TextNode, nodeValue)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNode*>(JS_GetOpaque(this_val, TextNode::classId));
  return JS_NewString(ctx, textNode->m_data.c_str());
}
IMPL_PROPERTY_SETTER(TextNode, nodeValue)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNode*>(JS_GetOpaque(this_val, TextNode::classId));
  textNode->internalSetTextContent(argv[0]);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(TextNode, nodeName)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NewString(ctx, "#text");
}

std::string TextNode::toString() {
  return m_data;
}

JSValue TextNode::internalGetTextContent() {
  return JS_NewString(m_ctx, m_data.c_str());
}
void TextNode::internalSetTextContent(JSValue content) {
  m_data = jsValueToStdString(m_ctx, content);

  std::string key = "data";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(m_ctx, content);
  context()->uiCommandBuffer()->addCommand(eventTargetId(), UICommand::setProperty, *args_01, *args_02, nullptr);
}
}  // namespace kraken
