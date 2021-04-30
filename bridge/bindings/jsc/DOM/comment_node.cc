/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "comment_node.h"

namespace kraken::binding::jsc {

void bindCommentNode(std::unique_ptr<JSContext> &context) {
  auto commentNode = JSCommentNode::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "CommentNode", commentNode->classObject);
}

JSCommentNode::JSCommentNode(JSContext *context) : JSNode(context, "CommentNode") {}

std::unordered_map<JSContext *, JSCommentNode *> JSCommentNode::instanceMap{};

JSCommentNode::~JSCommentNode() {
  instanceMap.erase(context);
}

JSObjectRef JSCommentNode::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                               const JSValueRef *arguments, JSValueRef *exception) {
  JSStringRef commentData = nullptr;

  if (argumentCount > 0) {
    commentData = JSValueToStringCopy(ctx, arguments[0], exception);
  }

  auto textNode = new CommentNodeInstance(this, commentData);
  return textNode->object;
}

JSCommentNode::CommentNodeInstance::CommentNodeInstance(JSCommentNode *jsCommentNode, JSStringRef data)
  : NodeInstance(jsCommentNode, NodeType::COMMENT_NODE), nativeComment(new NativeComment(nativeNode)) {
  if (data != nullptr) {
    m_data.setString(data);
  }

  std::string str = m_data.string();
  NativeString args_01{};
  buildUICommandArgs(str, args_01);

  ::foundation::UICommandTaskMessageQueue::instance(jsCommentNode->contextId)
    ->registerCommand(eventTargetId, UICommand::createComment, args_01, nativeComment);
}

bool JSCommentNode::CommentNodeInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  return NodeInstance::setProperty(name, value, exception);
}

JSValueRef JSCommentNode::CommentNodeInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getCommentNodePropertyMap();

  if (propertyMap.count(name) == 0) return NodeInstance::getProperty(name, exception);

  CommentNodeProperty property = propertyMap[name];

  switch (property) {
  case CommentNodeProperty::data:
    return m_data.makeString();
  case CommentNodeProperty::nodeName: {
    JSStringRef nodeName = JSStringCreateWithUTF8CString("#comment");
    return JSValueMakeString(_hostClass->ctx, nodeName);
  }
  case CommentNodeProperty::length:
    return JSValueMakeNumber(_hostClass->ctx, m_data.size());
  }
}

void JSCommentNode::CommentNodeInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  NodeInstance::getPropertyNames(accumulator);

  for (auto &property : getCommentNodePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::string JSCommentNode::CommentNodeInstance::internalGetTextContent() {
  return m_data.string();
}

JSCommentNode::CommentNodeInstance::~CommentNodeInstance() {
  ::foundation::UICommandCallbackQueue::instance()->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeComment *>(ptr);
  }, nativeComment);
}

void JSCommentNode::CommentNodeInstance::internalSetTextContent(JSStringRef content, JSValueRef *exception) {
  m_data.setString(content);
}

} // namespace kraken::binding::jsc
