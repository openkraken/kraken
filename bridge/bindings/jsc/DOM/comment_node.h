/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_COMMENT_NODE_H
#define KRAKENBRIDGE_COMMENT_NODE_H

#include "bindings/jsc/DOM/node.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

void bindCommentNode(std::unique_ptr<JSContext> &context);

struct NativeComment;

class JSCommentNode : public JSNode {
public:
  static std::unordered_map<JSContext *, JSCommentNode *> instanceMap;
  OBJECT_INSTANCE(JSCommentNode)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class CommentNodeInstance : public NodeInstance {
  public:
    DEFINE_OBJECT_PROPERTY(CommentNode, 3, data, nodeName, length)

    CommentNodeInstance() = delete;
    explicit CommentNodeInstance(JSCommentNode *jsCommentNode, JSStringRef data);
    ~CommentNodeInstance();
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    std::string internalGetTextContent() override;
    void internalSetTextContent(JSStringRef content, JSValueRef *exception) override;

    NativeComment *nativeComment;

  private:
    JSStringHolder m_data{context, ""};
  };
protected:
  JSCommentNode() = delete;
  explicit JSCommentNode(JSContext *context);
  ~JSCommentNode();
};

struct NativeComment {
  NativeComment() = delete;
  NativeComment(NativeNode *nativeNode) : nativeNode(nativeNode){};

  NativeNode *nativeNode;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_COMMENT_NODE_H
