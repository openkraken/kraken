/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "text_node.h"
#include "document.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

std::once_flag kTextNodeInitFlag;

void bindTextNode(std::unique_ptr<JSContext>& context) {
  auto* constructor = TextNode::instance(context.get());
  context->defineGlobalProperty("Text", constructor->jsObject);
}

JSClassID TextNode::kTextNodeClassId{0};

TextNode::TextNode(JSContext* context) : Node(context, "TextNode") {
  std::call_once(kTextNodeInitFlag, []() { JS_NewClassID(&kTextNodeClassId); });
  JS_SetPrototype(m_ctx, m_prototypeObject, Node::instance(m_context)->prototype());
}

JSValue TextNode::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  JSValue textContent = JS_NULL;
  if (argc == 1) {
    textContent = argv[0];
  }

  return (new TextNodeInstance(this, textContent))->jsObject;
}

JSClassID TextNode::classId() {
  return kTextNodeClassId;
}

IMPL_PROPERTY_GETTER(TextNode, data)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNodeInstance*>(JS_GetOpaque(this_val, TextNode::classId()));
  return JS_NewString(ctx, textNode->m_data.c_str());
}
IMPL_PROPERTY_SETTER(TextNode, data)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNodeInstance*>(JS_GetOpaque(this_val, TextNode::classId()));
  textNode->internalSetTextContent(argv[0]);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(TextNode, nodeValue)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNodeInstance*>(JS_GetOpaque(this_val, TextNode::classId()));
  return JS_NewString(ctx, textNode->m_data.c_str());
}
IMPL_PROPERTY_SETTER(TextNode, nodeValue)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNodeInstance*>(JS_GetOpaque(this_val, TextNode::classId()));
  textNode->internalSetTextContent(argv[0]);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(TextNode, nodeName)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NewString(ctx, "#text");
}

TextNodeInstance::TextNodeInstance(TextNode* textNode, JSValue text)
    : NodeInstance(textNode, NodeType::TEXT_NODE, DocumentInstance::instance(Document::instance(textNode->m_context)), TextNode::classId(), "TextNode") {
  m_data = jsValueToStdString(m_ctx, text);
  std::unique_ptr<NativeString> args_01 = stringToNativeString(m_data);
  foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(m_eventTargetId, UICommand::createTextNode, *args_01, nativeEventTarget);
}

TextNodeInstance::~TextNodeInstance() {}

std::string TextNodeInstance::toString() {
  return m_data;
}

JSValue TextNodeInstance::internalGetTextContent() {
  return JS_NewString(m_ctx, m_data.c_str());
}
void TextNodeInstance::internalSetTextContent(JSValue content) {
  m_data = jsValueToStdString(m_ctx, content);

  std::string key = "data";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(m_ctx, content);
  foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
}
}  // namespace kraken::binding::qjs
