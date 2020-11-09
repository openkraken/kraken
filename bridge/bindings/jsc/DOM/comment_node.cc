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
JSCommentNode *JSCommentNode::instance(JSContext *context) {
  static JSCommentNode *_instance{nullptr};
  if (_instance == nullptr) {
    _instance = new JSCommentNode(context);
  }
  return _instance;
}

JSObjectRef JSCommentNode::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                               const JSValueRef *arguments, JSValueRef *exception) {

  auto textNode = new CommentNodeInstance(this);
  return textNode->object;
}

JSCommentNode::CommentNodeInstance::CommentNodeInstance(JSCommentNode *jsCommentNode)
  : NodeInstance(jsCommentNode, NodeType::COMMENT_NODE) {
}


void JSCommentNode::CommentNodeInstance::setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) {
  NodeInstance::setProperty(name, value, exception);
  if (exception != nullptr) return;


}

JSValueRef JSCommentNode::CommentNodeInstance::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  JSValueRef nodeResult = NodeInstance::getProperty(nameRef, exception);
  if (nodeResult != nullptr) return nodeResult;

  std::string name = JSStringToStdString(nameRef);
  if (name == "data" || name == "textContent") {
    return JSValueMakeString(_hostClass->ctx, data);
  } else if (name == "nodeName") {
    JSStringRef nodeName = JSStringCreateWithUTF8CString("#comment");
    return JSValueMakeString(_hostClass->ctx, nodeName);
  } else if (name == "length") {
    return JSValueMakeNumber(_hostClass->ctx, JSStringGetLength(data));
  }

  return nullptr;
}

void JSCommentNode::CommentNodeInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  NodeInstance::getPropertyNames(accumulator);
}
} // namespace kraken::binding::jsc
