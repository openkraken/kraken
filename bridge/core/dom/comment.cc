/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "comment.h"
#include "document.h"

namespace kraken {

void bindCommentNode(std::unique_ptr<ExecutionContext>& context) {
  //  auto* constructor = Comment::instance(context.get());
  //  context->defineGlobalProperty("Comment", constructor->jsObject);
}

JSClassID Comment::classId{0};

Comment* Comment::create(JSContext* ctx) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  auto* comment = makeGarbageCollected<Comment>()->initialize<Comment>(ctx, &classId);

  JSValue prototype = context->contextData()->prototypeForType(&commentTypeInfo);

  // Let eventTarget instance inherit EventTarget prototype methods.
  JS_SetPrototype(ctx, comment->toQuickJS(), prototype);

  return comment;
}

// Comment::Comment(ExecutionContext* context) : Node(context, "Comment") {
//  std::call_once(kCommentInitFlag, []() { JS_NewClassID(&kCommentClassId); });
//  JS_SetPrototype(m_ctx, m_prototypeObject, Node::instance(m_context)->prototype());
//}

JSValue Comment::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  return (new CommentInstance(this))->jsObject;
}

IMPL_PROPERTY_GETTER(Comment, data)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NewString(ctx, "");
}

IMPL_PROPERTY_GETTER(Comment, nodeName)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NewString(ctx, "#comment");
}

IMPL_PROPERTY_GETTER(Comment, length)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NewUint32(ctx, 0);
}

CommentInstance::CommentInstance(Comment* comment)
    : NodeInstance(comment, NodeType::COMMENT_NODE, Comment::classId(), "Comment") {
  m_context->uiCommandBuffer()->addCommand(m_eventTargetId, UICommand::createComment, nativeEventTarget);
}

}  // namespace kraken
