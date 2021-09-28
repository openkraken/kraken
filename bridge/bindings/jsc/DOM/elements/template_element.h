/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEMPLATE_ELEMENT_H
#define KRAKENBRIDGE_TEMPLATE_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

void bindTemplateElement(std::unique_ptr<JSContext> &context);

class JSTemplateElement : public JSNode {
public:
  static std::unordered_map<JSContext *, JSTemplateElement *> instanceMap;
  OBJECT_INSTANCE(JSTemplateElement)
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class TemplateElementInstance : public NodeInstance {
  public:
    TemplateElementInstance() = delete;
    ~TemplateElementInstance();
    explicit TemplateElementInstance(JSTemplateElement *JSTemplateElement);

    JSTemplateElement *nativeTemplateElement;
  };

protected:
  ~JSTemplateElement();
  JSTemplateElement() = delete;
  explicit JSTemplateElement(JSContext *context);
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_TEMPLATE_ELEMENT_H
