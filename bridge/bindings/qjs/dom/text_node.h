/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEXT_NODE_H
#define KRAKENBRIDGE_TEXT_NODE_H

#include "node.h"

namespace kraken::binding::qjs {

class TextNodeInstance;

void bindTextNode(std::unique_ptr<ExecutionContext>& context);

class TextNode : public Node {
 public:
  static JSClassID classId;
  static JSValue constructor(ExecutionContext* context);
  static JSValue prototype(ExecutionContext* context);
  static TextNode* create(JSContext* ctx, JSValue textContent);

  TextNode() = delete;
  explicit TextNode(JSValueConst textContent);

  std::string toString();

  DEFINE_PROTOTYPE_READONLY_PROPERTY(nodeName);

  DEFINE_PROTOTYPE_PROPERTY(data);
  DEFINE_PROTOTYPE_PROPERTY(nodeValue);

 protected:
  JSValue internalGetTextContent() override;
  void internalSetTextContent(JSValue content) override;
  std::string m_data;
};

auto textNodeCreator = [](JSContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags) -> JSValue {
  JSValue textContent = JS_NULL;
  if (argc == 1) {
    textContent = argv[0];
  }

  TextNode* textNode = TextNode::create(ctx, textContent);
  return textNode->toQuickJS();
};

const WrapperTypeInfo textNodeType = {
    "TextNode",
    &nodeTypeInfo,
    textNodeCreator
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_TEXT_NODE_H
