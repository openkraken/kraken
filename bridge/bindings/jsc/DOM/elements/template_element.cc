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

JSTemplateElement::JSTemplateElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSTemplateElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                   const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new TemplateElementInstance(this);
  return instance->object;
}

JSTemplateElement::TemplateElementInstance::TemplateElementInstance(JSTemplateElement *JSTemplateElement)
  : ElementInstance(JSTemplateElement, "template", false) , nativeTemplateElement(new NativeTemplateElement(nativeElement)) {
  std::string tagName = "template";
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);

  std::string strDocumentFragment = "documentfragment";
  m_content = new JSDocumentFragment::DocumentFragmentInstance(JSDocumentFragment::instance(context));

  foundation::UICommandBuffer::instance(context->getContextId())
    ->addCommand(eventTargetId, UICommand::createElement, args_01, nativeTemplateElement);
}

bool JSTemplateElement::TemplateElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getTemplateElementPropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case TemplateElementProperty::content:
      return false;
    case TemplateElementProperty::innerHTML:
      HTMLParser::instance()->parseHTML(context, JSValueToStringCopy(ctx, value, exception), m_content);
    default:
      break;
    }
    return true;
  } else {
    return ElementInstance::setProperty(name, value, exception);
  }
}

JSValueRef JSTemplateElement::TemplateElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = getTemplateElementPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto &property = propertyMap[name];
    switch (property) {
      case TemplateElementProperty::content:
        return m_content->object;
      case TemplateElementProperty::innerHTML: {
        std::string s = "";
        for (auto iter : m_content->childNodes) {
          if (iter->nodeType == NodeType::ELEMENT_NODE) {
            ElementInstance* element = static_cast<ElementInstance *>(iter);
            s += element->toString();
          } else if (iter->nodeType == NodeType::TEXT_NODE) {
            JSTextNode::TextNodeInstance* textNode = static_cast<JSTextNode::TextNodeInstance *>(iter);
            s += textNode->toString();
          }
        }
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(s.c_str()));
      }
    }
  }

  return ElementInstance::getProperty(name, exception);
}

JSTemplateElement::TemplateElementInstance::~TemplateElementInstance() {}

} // namespace kraken::binding::jsc
