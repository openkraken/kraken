/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "text_node.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

void bindTextNode(std::unique_ptr<JSContext> &context) {
  auto textNode = JSTextNode::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "TextNode", textNode->classObject);
}

JSTextNode *JSTextNode::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSTextNode *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSTextNode(context);
  }
  return instanceMap[context];
}

JSTextNode::JSTextNode(JSContext *context) : JSNode(context, "TextNode") {}

JSObjectRef JSTextNode::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                            const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef dataValueRef = arguments[0];
  auto textNode = new TextNodeInstance(this, JSValueToStringCopy(ctx, dataValueRef, exception));
  return textNode->object;
}

JSTextNode::TextNodeInstance::TextNodeInstance(JSTextNode *jsTextNode, JSStringRef data)
  : NodeInstance(jsTextNode, NodeType::TEXT_NODE), nativeTextNode(new NativeTextNode(nativeNode)), data(JSStringRetain(data)) {
  NativeString textNodeData{};
  textNodeData.string = JSStringGetCharactersPtr(data);
  textNodeData.length = JSStringGetLength(data);

  auto args = new NativeString *[1];
  args[0] = textNodeData.clone();

  foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
    ->registerCommand(eventTargetId, UICommandType::createTextNode, args, 1, nativeTextNode);
}

JSValueRef JSTextNode::TextNodeInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getTextNodePropertyMap();

  if (!propertyMap.contains(name)) {
    return JSNode::NodeInstance::getProperty(name, exception);
  }

  auto property = propertyMap[name];
  switch (property) {
  case TextNodeProperty::kTextContent:
  case TextNodeProperty::kData: {
    return JSValueMakeString(_hostClass->ctx, data);
  }
  case TextNodeProperty::kNodeName: {
    JSStringRef nodeName = JSStringCreateWithUTF8CString("#text");
    return JSValueMakeString(_hostClass->ctx, nodeName);
  }
  }
}

void JSTextNode::TextNodeInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  if (name == "data") {
    JSStringRef stringRef = JSValueToStringCopy(_hostClass->ctx, value, exception);
    JSStringRetain(stringRef);

    if (data != nullptr) {
      // Should release the previous data string reference.
      JSStringRelease(data);
    }

    data = stringRef;
    NativeString property{};
    NativeString propertyValue{};
    propertyValue.string = JSStringGetCharactersPtr(stringRef);
    propertyValue.length = JSStringGetLength(stringRef);
    STD_STRING_TO_NATIVE_STRING("data", property);

    auto args = new NativeString *[2];
    args[0] = property.clone();
    args[1] = propertyValue.clone();

    foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommandType::setProperty, args, 2, nullptr);
  }
  JSNode::NodeInstance::setProperty(name, value, exception);
}

std::array<JSStringRef, 3> &JSTextNode::TextNodeInstance::getTextNodePropertyNames() {
  static std::array<JSStringRef, 3> propertyNames{JSStringCreateWithUTF8CString("data"),
                                                  JSStringCreateWithUTF8CString("textContent"),
                                                  JSStringCreateWithUTF8CString("nodeName")};
  return propertyNames;
}

void JSTextNode::TextNodeInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  NodeInstance::getPropertyNames(accumulator);

  for (auto &property : getTextNodePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSStringRef JSTextNode::TextNodeInstance::internalTextContent() {
  return data;
}

const std::unordered_map<std::string, JSTextNode::TextNodeInstance::TextNodeProperty> &
JSTextNode::TextNodeInstance::getTextNodePropertyMap() {
  static const std::unordered_map<std::string, TextNodeProperty> nodeProperty{
    {"data", TextNodeProperty::kData},
    {"textContent", TextNodeProperty::kTextContent},
    {"nodeName", TextNodeProperty::kNodeName}};
  return nodeProperty;
}

JSTextNode::TextNodeInstance::~TextNodeInstance() {
  delete nativeTextNode;
  if (data != nullptr) JSStringRelease(data);
}

} // namespace kraken::binding::jsc
