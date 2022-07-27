/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_TEXT_NODE_H
#define BRIDGE_TEXT_NODE_H

#include "node.h"

namespace webf::binding::qjs {

class TextNodeInstance;

void bindTextNode(ExecutionContext* context);

class TextNode : public Node {
 public:
  static JSClassID kTextNodeClassId;
  static JSClassID classId();
  TextNode() = delete;
  explicit TextNode(ExecutionContext* context);

  OBJECT_INSTANCE(TextNode);

  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

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

}  // namespace webf::binding::qjs

#endif  // BRIDGE_TEXT_NODE_H
