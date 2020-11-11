/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ANCHOR_ELEMENT_H
#define KRAKENBRIDGE_ANCHOR_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

class JSAnchorElement : public JSElement {
public:
  static JSAnchorElement *instance(JSContext *context);

  JSAnchorElement() = delete;
  explicit JSAnchorElement(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class AnchorElementInstance : public ElementInstance {
  public:
    static std::array<JSStringRef, 2> &getAnchorElementPropertyNames();

    AnchorElementInstance() = delete;
    AnchorElementInstance(JSAnchorElement *jsAnchorElement);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  private:
    JSStringRef _href;
    JSStringRef _target;
  };
};

}

#endif // KRAKENBRIDGE_ANCHOR_ELEMENT_H
