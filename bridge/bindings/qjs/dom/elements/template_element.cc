/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "template_element.h"
#include "bindings/qjs/dom/text_node.h"
#include "bindings/qjs/qjs_patch.h"
#include "page.h"

namespace kraken::binding::qjs {

TemplateElement::TemplateElement(ExecutionContext* context) : Element(context) {
  JS_SetPrototype(m_ctx, m_prototypeObject, Element::instance(m_context)->prototype());
}

void bindTemplateElement(std::unique_ptr<ExecutionContext>& context) {
  auto* constructor = TemplateElement::instance(context.get());
  context->defineGlobalProperty("HTMLTemplateElement", constructor->jsObject);
}

JSValue TemplateElement::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  auto instance = new TemplateElementInstance(this);
  return instance->jsObject;
}

DocumentFragmentInstance* TemplateElementInstance::content() const {
  return static_cast<DocumentFragmentInstance*>(JS_GetOpaque(m_content.value(), DocumentFragment::classId()));
}

TemplateElementInstance::TemplateElementInstance(TemplateElement* element) : ElementInstance(element, "template", true) {
  setNodeFlag(NodeFlag::IsTemplateElement);
}

TemplateElementInstance::~TemplateElementInstance() {}

void TemplateElementInstance::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  ElementInstance::trace(rt, val, mark_func);
}

}  // namespace kraken::binding::qjs
