/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEXT_NODE_H
#define KRAKENBRIDGE_TEXT_NODE_H

#include "bindings/jsc/DOM/node.h"
#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

void bindTextNode(std::unique_ptr<JSContext> &context);

struct NativeTextNode;

class JSTextNode : public JSNode {
public:
  JSTextNode() = delete;
  explicit JSTextNode(JSContext *context);

  static JSTextNode *instance(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class TextNodeInstance : public NodeInstance {
  public:
    enum class TextNodeProperty {
      kData,
      kTextContent,
      kNodeName
    };

    static std::array<JSStringRef, 3> &getTextNodePropertyNames();
    static const std::unordered_map<std::string, TextNodeProperty> &getTextNodePropertyMap();

    TextNodeInstance() = delete;
    ~TextNodeInstance();
    explicit TextNodeInstance(JSTextNode *jsTextNode, JSStringRef data);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    JSStringRef internalTextContent() override;

    NativeTextNode *nativeTextNode;

  private:
    JSStringRef data {nullptr};
  };
};

struct NativeTextNode {
  NativeTextNode() = delete;
  NativeTextNode(NativeNode *nativeNode) : nativeNode(nativeNode) {};

  NativeNode *nativeNode;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_TEXT_NODE_H
