/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_COMMENT_NODE_H
#define KRAKENBRIDGE_COMMENT_NODE_H

#include "node.h"

namespace kraken::binding::qjs {

void bindCommentNode(ExecutionContext* context);

class CommentInstance;

class Comment : public Node {
 public:
  static JSClassID kCommentClassId;
  static JSClassID classId();
  Comment() = delete;
  explicit Comment(ExecutionContext* context);

  OBJECT_INSTANCE(Comment);

  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

 private:
  DEFINE_PROTOTYPE_READONLY_PROPERTY(data);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(nodeName);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(length);

  friend CommentInstance;
};

class CommentInstance : public NodeInstance {
 public:
  CommentInstance() = delete;
  explicit CommentInstance(Comment* comment);

 private:
  friend Comment;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_COMMENT_NODE_H
