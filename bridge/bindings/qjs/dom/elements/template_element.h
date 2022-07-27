/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_TEMPLATE_ELEMENT_H
#define BRIDGE_TEMPLATE_ELEMENT_H

#include "bindings/qjs/dom/document_fragment.h"
#include "bindings/qjs/dom/element.h"

namespace webf::binding::qjs {

void bindTemplateElement(ExecutionContext* context);
class TemplateElementInstance;

class TemplateElement : public Element {
 public:
  TemplateElement() = delete;
  explicit TemplateElement(ExecutionContext* context);
  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  OBJECT_INSTANCE(TemplateElement);

 private:
  friend TemplateElementInstance;
};

class TemplateElementInstance : public ElementInstance {
 public:
  TemplateElementInstance() = delete;
  explicit TemplateElementInstance(TemplateElement* element);
  ~TemplateElementInstance();

  DocumentFragmentInstance* content() const;

 protected:
  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;

 private:
  ObjectProperty m_content{m_context, jsObject, "content", JS_CallConstructor(m_ctx, DocumentFragment::instance(m_context)->jsObject, 0, nullptr)};
  friend TemplateElement;
};

}  // namespace webf::binding::qjs

#endif  // BRIDGE_TEMPLATE_ELEMENTT_H
