/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_COMMENT_NODE_H
#define KRAKENBRIDGE_COMMENT_NODE_H

#include "node.h"

namespace kraken::binding::qjs {

void bindCommentNode(std::unique_ptr<JSContext>& context);

class CommentInstance;

class Comment : public Node {
 public:
  static JSClassID kCommentClassId;
  static JSClassID classId();
  Comment() = delete;
  explicit Comment(JSContext* context);

  OBJECT_INSTANCE(Comment);

  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

 private:
  friend CommentInstance;
};

class CommentInstance : public NodeInstance {
 public:
  CommentInstance() = delete;
  explicit CommentInstance(Comment* comment);

 private:
  DEFINE_HOST_CLASS_PROPERTY(3, data, nodeName, length)

  friend Comment;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_COMMENT_NODE_H
