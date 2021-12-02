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
  context->defineGlobalProperty("Text", constructor->classObject);
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

  return (new TextNodeInstance(this, textContent))->instanceObject;
}

JSClassID TextNode::classId() {
  return kTextNodeClassId;
}

PROP_GETTER(TextNodeInstance, data)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNodeInstance*>(JS_GetOpaque(this_val, TextNode::classId()));
  return JS_DupValue(ctx, textNode->m_data);
}
PROP_SETTER(TextNodeInstance, data)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNodeInstance*>(JS_GetOpaque(this_val, TextNode::classId()));
  textNode->internalSetTextContent(argv[0]);
  return JS_NULL;
}

PROP_GETTER(TextNodeInstance, nodeValue)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNodeInstance*>(JS_GetOpaque(this_val, TextNode::classId()));
  return JS_DupValue(ctx, textNode->m_data);
}
PROP_SETTER(TextNodeInstance, nodeValue)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* textNode = static_cast<TextNodeInstance*>(JS_GetOpaque(this_val, TextNode::classId()));
  textNode->internalSetTextContent(argv[0]);
  return JS_NULL;
}

PROP_GETTER(TextNodeInstance, nodeName)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NewString(ctx, "#text");
}
PROP_SETTER(TextNodeInstance, nodeName)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

TextNodeInstance::TextNodeInstance(TextNode* textNode, JSValue text)
    : NodeInstance(textNode, NodeType::TEXT_NODE, DocumentInstance::instance(Document::instance(textNode->m_context)), TextNode::classId(), "TextNode"), m_data(JS_DupValue(m_ctx, text)) {
  std::unique_ptr<NativeString> args_01 = jsValueToNativeString(m_ctx, m_data);
  foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(m_eventTargetId, UICommand::createTextNode, *args_01, nativeEventTarget);
}

TextNodeInstance::~TextNodeInstance() {
  JS_FreeValue(m_ctx, m_data);
}

std::string TextNodeInstance::toString() {
  const char* pstring = JS_ToCString(m_ctx, m_data);
  std::string result = std::string(pstring);
  JS_FreeCString(m_ctx, pstring);
  return result;
}

JSValue TextNodeInstance::internalGetTextContent() {
  return JS_DupValue(m_ctx, m_data);
}
void TextNodeInstance::internalSetTextContent(JSValue content) {
  if (!JS_IsNull(m_data)) {
    JS_FreeValue(m_ctx, m_data);
  }

  m_data = JS_DupValue(m_ctx, content);

  std::string key = "data";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(m_ctx, content);
  foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
}
}  // namespace kraken::binding::qjs
