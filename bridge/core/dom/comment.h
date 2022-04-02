/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_COMMENT_H
#define KRAKENBRIDGE_COMMENT_H

#include "node.h"

namespace kraken {

void bindCommentNode(ExecutionContext* context);

class CommentInstance;

class Comment : public Node {
 public:
  static JSClassID classId;
  static Comment* create(JSContext* ctx);
  static JSValue constructor(ExecutionContext* context);
  static JSValue prototype(ExecutionContext* context);

  //  static JSClassID kCommentClassId;
  //  static JSClassID classId();
  //  Comment() = delete;
  //  explicit Comment(ExecutionContext* context);

  //  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

 private:
  DEFINE_PROTOTYPE_READONLY_PROPERTY(data);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(nodeName);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(length);

  friend CommentInstance;
};

auto commentCreator =
    [](JSContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags)
    -> JSValue {};

const WrapperTypeInfo commentTypeInfo = {"Comment", &nodeTypeInfo, commentCreator};

//
// class CommentInstance : public NodeInstance {
// public:
//  CommentInstance() = delete;
//  explicit CommentInstance(Comment* comment);
//
// private:
//  friend Comment;
//};

}  // namespace kraken

#endif  // KRAKENBRIDGE_COMMENT_H
