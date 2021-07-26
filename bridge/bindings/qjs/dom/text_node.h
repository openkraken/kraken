/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEXT_NODE_H
#define KRAKENBRIDGE_TEXT_NODE_H

#include "node.h"

namespace kraken::binding::qjs {

class TextNodeInstance;

void bindTextNode(std::unique_ptr<JSContext> &context);

class TextNode : public Node {
public:
  static JSClassID kTextNodeClassId;
  static JSClassID classId();
  TextNode() = delete;
  explicit TextNode(JSContext *context);

  OBJECT_INSTANCE(TextNode);

  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;
private:
  DEFINE_HOST_CLASS_PROPERTY(4, data, textContent, nodeValue, nodeName);
  friend TextNodeInstance;
};

class TextNodeInstance : public NodeInstance {
public:
  TextNodeInstance() = delete;
  explicit TextNodeInstance(TextNode *textNode, JSValue textData);
  ~TextNodeInstance();
private:
  JSValue internalGetTextContent() override;
  void internalSetTextContent(JSValue content) override;
  friend TextNode;
  friend Node;

  JSValue m_data{JS_NULL};
};



}

#endif //KRAKENBRIDGE_TEXT_NODE_H
