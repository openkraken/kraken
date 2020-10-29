/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "include/kraken_bridge.h"
#include "node.h"

namespace kraken::binding::jsc {

void bindElement(std::unique_ptr<JSContext> &context);

class JSElement : public JSNode {
public:
  static JSElement *instance(JSContext *context);

  JSElement() = delete;
  explicit JSElement(JSContext *context);

  class ElementInstance : public EventTargetInstance {
  public:
    ElementInstance() = delete;
    explicit ElementInstance(JSElement *element, size_t argumentsCount, const JSValueRef *arguments, JSValueRef *exception);
    void initialized() override;
  };
};

} // namespace kraken::binding::jsc
#endif // KRAKENBRIDGE_ELEMENT_H
