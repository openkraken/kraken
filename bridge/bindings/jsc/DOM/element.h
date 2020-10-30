/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "include/kraken_bridge.h"
#include "node.h"

#define BODY_TARGET_ID -1

namespace kraken::binding::jsc {

void bindElement(std::unique_ptr<JSContext> &context);

class JSElement : public JSNode {
public:
  static JSElement *instance(JSContext *context);

  JSElement() = delete;
  explicit JSElement(JSContext *context);

  JSObjectRef constructInstance(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) override;

  class ElementInstance : public EventTargetInstance {
  public:
    ElementInstance() = delete;
    explicit ElementInstance(JSElement *element, JSValueRef tagNameValue, double targetId, JSValueRef *exception);
    void initialized() override;
  };
};

} // namespace kraken::binding::jsc
#endif // KRAKENBRIDGE_ELEMENT_H
