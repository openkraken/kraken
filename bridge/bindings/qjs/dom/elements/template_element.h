/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEMPLATE_ELEMENT_H
#define KRAKENBRIDGE_TEMPLATE_ELEMENT_H

#include "bindings/qjs/dom/document_fragment.h"
#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {

void bindTemplateElement(std::unique_ptr<JSContext>& context);

class TemplateElement : public Element {
 public:
  TemplateElement() = delete;
  explicit TemplateElement(JSContext* context);
  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  OBJECT_INSTANCE(TemplateElement);

 private:
};
class TemplateElementInstance : public ElementInstance {
 public:
  TemplateElementInstance() = delete;
  explicit TemplateElementInstance(TemplateElement* element);
  ~TemplateElementInstance();

 protected:
  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;

 private:
  DocumentFragmentInstance* m_content{nullptr};
  DEFINE_HOST_CLASS_PROPERTY(2, content, innerHTML)
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_TEMPLATE_ELEMENTT_H
