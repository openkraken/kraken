/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEXT_NODE_H
#define KRAKENBRIDGE_TEXT_NODE_H

#include "node.h"

namespace kraken::binding::qjs {

class TextNodeInstance;

void bindTextNode(std::unique_ptr<JSContext>& context);

class TextNode : public Node {
 public:
  static JSClassID kTextNodeClassId;
  static JSClassID classId();
  TextNode() = delete;
  explicit TextNode(JSContext* context);

  OBJECT_INSTANCE(TextNode);

  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

 private:
  DEFINE_PROTOTYPE_READONLY_PROPERTY(nodeName);

  DEFINE_PROTOTYPE_PROPERTY(data);
  DEFINE_PROTOTYPE_PROPERTY(nodeValue);
  friend TextNodeInstance;
};

class TextNodeInstance : public NodeInstance {
 public:
  TextNodeInstance() = delete;
  explicit TextNodeInstance(TextNode* textNode, JSValue textData);
  ~TextNodeInstance();

  std::string toString();

 private:
  JSValue internalGetTextContent() override;
  void internalSetTextContent(JSValue content) override;
  friend TextNode;
  friend Node;

  std::string m_data;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_TEXT_NODE_H
