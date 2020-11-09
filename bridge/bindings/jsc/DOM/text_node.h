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

class JSTextNode : public JSNode {
public:
  JSTextNode() = delete;
  explicit JSTextNode(JSContext *context);

  static JSTextNode *instance(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class TextNodeInstance : public NodeInstance {
  public:
    static std::array<JSStringRef, 3> &getTextNodePropertyNames();

    TextNodeInstance() = delete;
    explicit TextNodeInstance(JSTextNode *jsTextNode, JSStringRef data);
    JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
    void setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    JSStringRef internalTextContent() override;
  private:
    JSStringRef data {nullptr};
  };
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_TEXT_NODE_H
