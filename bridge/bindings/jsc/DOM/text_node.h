/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEXT_NODE_H
#define KRAKENBRIDGE_TEXT_NODE_H

#include "bindings/jsc/DOM/node.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

void bindTextNode(std::unique_ptr<JSContext> &context);

struct NativeTextNode;

class JSTextNode : public JSNode {
public:
  static std::unordered_map<JSContext *, JSTextNode *> instanceMap;
  static JSTextNode *instance(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class TextNodeInstance : public NodeInstance {
  public:
    DEFINE_OBJECT_PROPERTY(TextNode, 4, data, textContent, nodeValue, nodeName)

    TextNodeInstance() = delete;
    ~TextNodeInstance();
    explicit TextNodeInstance(JSTextNode *jsTextNode, JSStringRef data);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    std::string internalGetTextContent() override;
    void internalSetTextContent(JSStringRef content, JSValueRef *exception) override;

    NativeTextNode *nativeTextNode {nullptr};
    std::string toString();

  private:
    JSStringHolder m_data{context, ""};
  };

protected:
  JSTextNode() = delete;
  ~JSTextNode();
  explicit JSTextNode(JSContext *context);
};

struct NativeTextNode {
  NativeTextNode() = delete;
  NativeTextNode(NativeNode *nativeNode) : nativeNode(nativeNode) {};

  NativeNode *nativeNode;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_TEXT_NODE_H
