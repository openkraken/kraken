/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "text_node.h"

namespace kraken::binding::jsc {

void bindTextNode(std::unique_ptr<JSContext> &context) {
  auto textNode = JSTextNode::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Text", textNode->classObject);
}

std::unordered_map<JSContext *, JSTextNode *> JSTextNode::instanceMap{};

JSTextNode *JSTextNode::instance(JSContext *context) {
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSTextNode(context);
  }
  return instanceMap[context];
}
JSTextNode::~JSTextNode() {
  instanceMap.erase(context);
}

JSTextNode::JSTextNode(JSContext *context) : JSNode(context, "Text") {}

JSObjectRef JSTextNode::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                            const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef dataValueRef = arguments[0];
  auto textNode = new TextNodeInstance(this, JSValueToStringCopy(ctx, dataValueRef, exception));
  return textNode->object;
}

JSTextNode::TextNodeInstance::TextNodeInstance(JSTextNode *jsTextNode, JSStringRef data)
  : NodeInstance(jsTextNode, NodeType::TEXT_NODE), nativeTextNode(new NativeTextNode(nativeNode)) {

  m_data.setString(data);

  NativeString args_01{};
  buildUICommandArgs(data, args_01);
  foundation::UICommandBuffer::instance(_hostClass->contextId)
    ->addCommand(eventTargetId, UICommand::createTextNode, args_01, nativeTextNode);
}

JSValueRef JSTextNode::TextNodeInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = getTextNodePropertyMap();

  if (propertyMap.count(name) == 0) {
    return NodeInstance::getProperty(name, exception);
  }

  auto &property = propertyMap[name];
  switch (property) {
  case TextNodeProperty::nodeValue:
  case TextNodeProperty::textContent:
  case TextNodeProperty::data: {
    return m_data.makeString();
  }
  case TextNodeProperty::nodeName: {
    JSStringRef nodeName = JSStringCreateWithUTF8CString("#text");
    return JSValueMakeString(_hostClass->ctx, nodeName);
  }
  }
}

bool JSTextNode::TextNodeInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  if (name == "data" || name == "nodeValue") {
    JSStringRef data = JSValueToStringCopy(_hostClass->ctx, value, exception);
    m_data.setString(data);

    std::string dataString = JSStringToStdString(data);
    NativeString args_01{};
    NativeString args_02{};
    buildUICommandArgs(name, dataString, args_01, args_02);
    foundation::UICommandBuffer::instance(_hostClass->contextId)
      ->addCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
    return true;
  } else {
    return NodeInstance::setProperty(name, value, exception);
  }
}

void JSTextNode::TextNodeInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  NodeInstance::getPropertyNames(accumulator);

  for (auto &property : getTextNodePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::string JSTextNode::TextNodeInstance::internalGetTextContent() {
  return m_data.string();
}

JSTextNode::TextNodeInstance::~TextNodeInstance() {
  foundation::UICommandCallbackQueue::instance()->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeTextNode *>(ptr);
  }, nativeTextNode);
}

void JSTextNode::TextNodeInstance::internalSetTextContent(JSStringRef content, JSValueRef *exception) {
  m_data.setString(content);

  std::string key = "data";
  NativeString args_01{};
  NativeString args_02{};
  buildUICommandArgs(key, content, args_01, args_02);
  foundation::UICommandBuffer::instance(context->getContextId())
    ->addCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
}

std::string JSTextNode::TextNodeInstance::toString() {
  return m_data.string();
}

} // namespace kraken::binding::jsc
