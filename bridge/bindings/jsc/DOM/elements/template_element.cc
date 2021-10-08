/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "template_element.h"

namespace kraken::binding::jsc {

void bindTemplateElement(std::unique_ptr<JSContext> &context) {
  auto TemplateElement = JSTemplateElement::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "TemplateElement", TemplateElement->classObject);
}

std::unordered_map<JSContext *, JSTemplateElement *> JSTemplateElement::instanceMap{};

JSTemplateElement::~JSTemplateElement() {
  instanceMap.erase(context);
}

JSTemplateElement::JSTemplateElement(JSContext *context) : JSNode(context) {}
JSObjectRef JSTemplateElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                   const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new TemplateElementInstance(this);
  return instance->object;
}

JSTemplateElement::TemplateElementInstance::TemplateElementInstance(JSTemplateElement *JSTemplateElement)
  : NodeInstance(JSTemplateElement, NodeType::ELEMENT_NODE) {
  std::string tagName = "template";
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);
  
  foundation::UICommandBuffer::instance(context->getContextId())
    ->addCommand(eventTargetId, UICommand::createElement, args_01, nativeTemplateElement);
}

JSTemplateElement::TemplateElementInstance::~TemplateElementInstance() {}

} // namespace kraken::binding::jsc
