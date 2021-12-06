/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "template_element.h"
#include "bindings/qjs/dom/text_node.h"
#include "bindings/qjs/qjs_patch.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {

TemplateElement::TemplateElement(JSContext* context) : Element(context) {
  JS_SetPrototype(m_ctx, m_prototypeObject, Element::instance(m_context)->prototype());
}

void bindTemplateElement(std::unique_ptr<JSContext>& context) {
  auto* constructor = TemplateElement::instance(context.get());
  context->defineGlobalProperty("HTMLTemplateElement", constructor->classObject);
}

JSValue TemplateElement::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  auto instance = new TemplateElementInstance(this);
  return instance->instanceObject;
}
PROP_GETTER(TemplateElementInstance, content)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<TemplateElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return JS_DupValue(ctx, element->m_content->instanceObject);
}
PROP_SETTER(TemplateElementInstance, content)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}
PROP_GETTER(TemplateElementInstance, innerHTML)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<TemplateElementInstance*>(JS_GetOpaque(this_val, Element::classId()));

  std::string s = "";
  for (auto &node : element->m_content->childNodes) {
    if (node->nodeType == NodeType::ELEMENT_NODE) {
      s += reinterpret_cast<ElementInstance*>(node)->outerHTML();
    } else if (node->nodeType == NodeType::TEXT_NODE) {
      s += reinterpret_cast<TextNodeInstance*>(node)->toString();
    }
  }
  return JS_NewString(ctx, s.c_str());
}
PROP_SETTER(TemplateElementInstance, innerHTML)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<TemplateElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  const char* codeString = JS_ToCString(ctx, argv[0]);
  size_t len = strlen(codeString);
  HTMLParser::parseHTML(codeString, len, element->m_content);
  return JS_NULL;
}

TemplateElementInstance::TemplateElementInstance(TemplateElement* element) : ElementInstance(element, "template", true) {
  JSValue documentFragmentValue = JS_CallConstructor(m_ctx, DocumentFragment::instance(m_context)->classObject, 0, nullptr);
  m_content = static_cast<DocumentFragmentInstance*>(JS_GetOpaque(documentFragmentValue, DocumentFragment::classId()));
}

TemplateElementInstance::~TemplateElementInstance() {
  JS_FreeValue(m_ctx, m_content->instanceObject);
}

void TemplateElementInstance::gcMark(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  NodeInstance::gcMark(rt, val, mark_func);
  // Should check object is already inited before gc mark.
  if (JS_IsObject(m_content->instanceObject))
    JS_MarkValue(rt, m_content->instanceObject, mark_func);
}

}  // namespace kraken::binding::qjs
